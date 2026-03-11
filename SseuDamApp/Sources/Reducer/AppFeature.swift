//
//  AppFeature.swift
//  SseuDamApp
//
//  Created by Wonji Suh  on 11/19/25.
//

import ComposableArchitecture
import LoginFeature
import MainFeature
import SplashFeature
import ProfileFeature
@preconcurrency import Domain
import Foundation
import Data

@Reducer
struct AppFeature {

    @Dependency(\.analyticsUseCase) var analyticsUseCase

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var splash: SplashFeature.State?
        var login: LoginCoordinator.State?
        var main: MainCoordinator.State?
        var pendingDeepLink: PendingDeepLink?
        @Shared(.appStorage("sessionId")) var sessionId: String? = ""
        @Shared(.appStorage("appVersion")) var appVersion: String? = ""

        init() {
            self.splash = .init()
            self.login = nil
            self.main = nil
            self.pendingDeepLink = nil
            self.$appVersion.withLock { $0  =   Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""}
        }
    }

    // MARK: - Action

    enum Action: ViewAction {
        case view(View)
        case inner(InnerAction)
        case scope(ScopeAction)
    }

    enum Flow {
        case splash
        case login
        case main
    }

    @CasePathable
    enum View {
        case presentLogin
        case presentMain
        case handleDeepLink(String)
        case handlePushNotificationDeepLink(String)
    }

    enum InnerAction {
        case setLoginState
        case setMainState
        case handleDeepLinkJoin(String)
        case setPendingDeepLink(PendingDeepLink?)
        case setupPushNotificationObserver
        case handlePushDeepLink(String)
        case checkPendingPushDeepLink
        case startTokenExpiryListener        // ✅ 토큰 만료 리스너 시작
        case handleTokenExpiry               // ✅ 토큰 만료 처리
    }

    @CasePathable
    enum ScopeAction {
        case login(LoginCoordinator.Action)
        case splash(SplashFeature.Action)
        case main(MainCoordinator.Action)
    }

    enum PendingDeepLink: Equatable {
        case invite(String)
        case push(String)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.sessionUseCase) var sessionUseCase


    nonisolated enum CancelID: Hashable {
        case transitionToLogin
        case transitionToMain
        case transitionToProfile
        case refreshTokenExpiredListener    // 토큰 만료 리스너
    }

    // MARK: - body

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .view(let viewAction):
                    return handleViewAction(&state, action: viewAction)

                case .inner(let innerAction):
                    return handleInnerAction(&state, action: innerAction)

                case .scope(let scopeAction):
                    return handleScopeAction(&state, action: scopeAction)
            }
        }
        .ifLet(\.login, action: \.scope.login) {
            LoginCoordinator()
        }
        .ifLet(\.splash, action: \.scope.splash) {
            SplashFeature()
        }
        .ifLet(\.main, action: \.scope.main) {
            MainCoordinator()
        }
    }
}

extension AppFeature.State {
    var flow: AppFeature.Flow {
        if main != nil { return .main }
        if login != nil { return .login }
        return .splash
    }

    var caseKey: String {
        if main != nil { return "main" }
        if login != nil { return "login" }
        return "splash"
    }
}

extension AppFeature {
    func handleViewAction(
        _ state: inout State,
        action: View
    ) -> Effect<Action> {
        switch action {
            case .presentLogin:
                return .merge(
                    .cancel(id: CancelID.transitionToLogin),
                    .cancel(id: CancelID.transitionToMain),
                    .send(.inner(.setLoginState))
                )

            case .presentMain:
                return .merge(
                    .cancel(id: CancelID.transitionToLogin),
                    .cancel(id: CancelID.transitionToMain),
                    .send(.inner(.setMainState))
                )

            case .handleDeepLink(let urlString):
                var processedUrlString = urlString
                if urlString.hasPrefix("https://sseudam.up.railway.app/") {
                    processedUrlString = urlString.replacingOccurrences(
                        of: "https://sseudam.up.railway.app/",
                        with: "sseudam://"
                    )
                }

                guard let url = URL(string: processedUrlString) else { return .none }

                // Kakao 로그인 ticket/code 수신 시 저장
                if url.scheme == "sseudam",
                   url.host == "oauth",
                   url.path == "/kakao",
                   let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let ticket = components.queryItems?.first(where: { $0.name == "ticket" || $0.name == "code" })?.value {
                    Task {
                        await  KakaoAuthCodeStore.shared.save(ticket)
                    }
                }

                var inviteCode: String?
                if url.scheme == "sseudam",
                   let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    inviteCode = components.queryItems?.first(where: {
                        $0.name == "inviteCode" || $0.name == "code"
                    })?.value
                }

                if let code = inviteCode {
                    return .send(.inner(.handleDeepLinkJoin(code)))
                }

                return .none

            case .handlePushNotificationDeepLink(let urlString):
                return .send(.inner(.handlePushDeepLink(urlString)))
        }
    }

    func handleInnerAction(
        _ state: inout State,
        action: InnerAction
    ) -> Effect<Action> {
        switch action {
            case .setLoginState:
                state.login = .init()
                state.splash = nil
                state.main = nil
                return .none

            case .setMainState:
                let pending = state.pendingDeepLink
                state.pendingDeepLink = nil

                let inviteCode: String?
                if case .invite(let code) = pending {
                    inviteCode = code
                } else {
                    inviteCode = nil
                }

                state.main = .init(pendingInviteCode: inviteCode)
                state.splash = nil
                state.login = nil

                // 토큰 만료 리스너 시작
                let tokenExpiryEffect = Effect<Action>.send(.inner(.startTokenExpiryListener))

                // 대기 중인 푸시 딥 링크가 있으면 처리
                if case .push(let deepLink) = pending {
                    return .merge(
                        tokenExpiryEffect,
                        .send(.inner(.handlePushDeepLink(deepLink)))
                    )
                }

                return tokenExpiryEffect

            case .handleDeepLinkJoin(let inviteCode):
                // 딥링크를 통한 여행 참여 처리 (팝업 우선 표시)
                return .run { [sessionId = state.sessionId,
                               sessionUseCase,
                               hasMain = state.main != nil] send in
                    let hasValidSession: Bool = await {
                        guard let sid = sessionId, !sid.isEmpty else { return false }
                        return (try? await sessionUseCase.checkSession(sessionId: sid)) != nil
                    }()

                    if hasValidSession {
                        if hasMain {
                            await send(.scope(.main(.router(.routeAction(id: 0, action: .travelList(.openInviteCode(inviteCode)))))))
                            await send(.scope(.main(.refreshTravelList)))
                            await send(.inner(.setPendingDeepLink(nil)))
                        } else {
                            await send(.inner(.setPendingDeepLink(.invite(inviteCode))))
                            await send(.view(.presentMain))
                        }
                    } else {
                        await send(.inner(.setPendingDeepLink(.invite(inviteCode))))
                        await send(.view(.presentLogin))
                    }
                }

            case .setPendingDeepLink(let pending):
                state.pendingDeepLink = pending
                return .none

            case .handlePushDeepLink(let urlString):
                guard state.main != nil else {
                    state.pendingDeepLink = .push(urlString)
                    return .send(.view(.presentMain))
                }

                return .send(.scope(.main(.handlePushDeepLink(urlString))))

            case .checkPendingPushDeepLink:
                return .run { send in
                    // UserDefaults에서 대기 중인 푸시 딥 링크 확인
                    if let pendingDeepLink = UserDefaults.standard.string(forKey: UserDefaultsKey.pendingPushDeepLink.rawValue) {
                        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.pendingPushDeepLink.rawValue)
                        await send(.inner(.setPendingDeepLink(.push(pendingDeepLink))))
                    }
                }

            case .startTokenExpiryListener:
                return setupRefreshTokenExpiredListener()

            case .handleTokenExpiry:
                // 토큰 만료 시 로그인 화면으로 이동
                return .send(.view(.presentLogin))

            case .setupPushNotificationObserver:
                return .run { send in
                    for await notification in NotificationCenter.default.notifications(named: .pushNotificationDeepLink) {
                        if let urlString = notification.userInfo?["url"] as? String,
                           let deeplinkType = notification.userInfo?["deeplink_type"] as? String {

                            // Analytics 이벤트 전송
                            analyticsUseCase.track(.deeplink(DeeplinkEventData(deeplink: urlString, type: deeplinkType)))

                            await send(.view(.handlePushNotificationDeepLink(urlString)))
                        }
                    }
                }
        }
    }

    func handleScopeAction(
        _ state: inout State,
        action: ScopeAction
    ) -> Effect<Action> {
        switch action {
            case .splash(.delegate(.presentLogin)):
                return .send(.view(.presentLogin), animation: .easeIn(duration: 0.18))

            case .splash(.delegate(.presentMain)):
                return .send(.view(.presentMain), animation: .easeIn(duration: 0.18))

            case .login(.delegate(.presentMain)):
                let effect: Effect<Action> = .send(.view(.presentMain), animation: .easeIn(duration: 0.18))

                // 로그인 후 대기 중인 푸시 딥 링크가 있으면 처리
                if case .push(let pendingDeepLink) = state.pendingDeepLink {
                    return .merge(
                        effect,
                        .run { send in
                            // 메인 화면이 로드된 후 딥 링크 처리
                            await send(.inner(.handlePushDeepLink(pendingDeepLink)))
                        }
                    )
                }

                return effect

            case .main(.delegate(.presentLogin)):
                return .send(
                    .view(.presentLogin),
                    animation: .interactiveSpring(
                        response: 0.5,
                        dampingFraction: 0.9,
                        blendDuration: 0.1
                    )
                )


            default:
                return .none
        }
    }

    // MARK: - 토큰 만료 리스너 설정 (효율적인 Publisher 패턴)
    private func setupRefreshTokenExpiredListener() -> Effect<Action> {
        return .publisher {
            NotificationCenter.default
                .publisher(for: .refreshTokenExpired)
                .map { _ in Action.inner(.handleTokenExpiry) }
        }
        .cancellable(id: CancelID.refreshTokenExpiredListener, cancelInFlight: true)
    }
}
