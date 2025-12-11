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

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var splash: SplashFeature.State?
        var login: LoginCoordinator.State?
        var main: MainCoordinator.State?
        var pendingInviteCode: String?
        var pendingPushDeepLink: String?
        @Shared(.appStorage("sessionId")) var sessionId: String? = ""
        @Shared(.appStorage("appVersion")) var appVersion: String? = ""

        init() {
            self.splash = .init()
            self.login = nil
            self.main = nil
            self.pendingInviteCode = nil
            self.pendingPushDeepLink = nil
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
        case setPendingInviteCode(String?)
        case setupPushNotificationObserver
        case handlePushDeepLink(String)
        case setPendingPushDeepLink(String?)
        case checkPendingPushDeepLink
    }

    @CasePathable
    enum ScopeAction {
        case login(LoginCoordinator.Action)
        case splash(SplashFeature.Action)
        case main(MainCoordinator.Action)
    }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.sessionUseCase) var sessionUseCase


    nonisolated enum CancelID: Hashable {
        case transitionToLogin
        case transitionToMain
        case transitionToProfile
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
                print("🔗 Processing push notification deep link: \(urlString)")
                print("🔍 Current app state: \(state.flow)")
                print("🔍 Current sessionId: \(state.sessionId ?? "nil")")

                return .run { [sessionId = state.sessionId, sessionUseCase] send in
                    // 세션 체크
                    let hasValidSession: Bool = await {
                        guard let sid = sessionId, !sid.isEmpty else {
                            return false
                        }
                        do {
                            let result = try await sessionUseCase.checkSession(sessionId: sid)
                            return true
                        } catch {
                            return false
                        }
                    }()


                    if hasValidSession {
                        await send(.inner(.handlePushDeepLink(urlString)))
                    } else {
                        await send(.inner(.setPendingPushDeepLink(urlString)))
                        await send(.view(.presentLogin))
                    }
                }
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
                let inviteCode = state.pendingInviteCode
                let pushDeepLink = state.pendingPushDeepLink
                state.pendingInviteCode = nil
                state.pendingPushDeepLink = nil
                state.main = .init(pendingInviteCode: inviteCode)
                state.splash = nil
                state.login = nil

                // 대기 중인 푸시 딥 링크가 있으면 처리
                if let deepLink = pushDeepLink {
                    return .send(.inner(.handlePushDeepLink(deepLink)))
                }

                return .none

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
                            await send(.inner(.setPendingInviteCode(nil)))
                        } else {
                            await send(.inner(.setPendingInviteCode(inviteCode)))
                            await send(.view(.presentMain))
                        }
                    } else {
                        await send(.inner(.setPendingInviteCode(inviteCode)))
                        await send(.view(.presentLogin))
                    }
                }

            case .setPendingInviteCode(let code):
                state.pendingInviteCode = code
                return .none

            case .setupPushNotificationObserver:
                return .run { send in
                    print("🔔 Setting up push notification observer...")
                    // NotificationCenter 관찰자 설정
                    for await notification in NotificationCenter.default.notifications(named: .pushNotificationDeepLink) {
                        if let urlString = notification.userInfo?["url"] as? String {
                            await send(.view(.handlePushNotificationDeepLink(urlString)))
                        } else {
                        }
                    }
                }

            case .handlePushDeepLink(let urlString):
                guard state.main != nil else {
                    state.pendingPushDeepLink = urlString
                    return .send(.view(.presentMain))
                }

                return .send(.scope(.main(.handlePushDeepLink(urlString))))

            case .setPendingPushDeepLink(let urlString):
                state.pendingPushDeepLink = urlString
                return .none

            case .checkPendingPushDeepLink:
                return .run { send in
                    // UserDefaults에서 대기 중인 푸시 딥 링크 확인
                    if let pendingDeepLink = UserDefaults.standard.string(forKey: "pendingPushDeepLink") {
                        UserDefaults.standard.removeObject(forKey: "pendingPushDeepLink")
                        await send(.inner(.setPendingPushDeepLink(pendingDeepLink)))
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
                if let pendingDeepLink = state.pendingPushDeepLink {
                    return .merge(
                        effect,
                        .run { send in
                            // 메인 화면이 로드된 후 딥 링크 처리
                            try await clock.sleep(for: .milliseconds(300))
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
}
