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

@Reducer
struct AppFeature {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var splash: SplashFeature.State?
        var login: LoginCoordinator.State?
        var main: MainCoordinator.State?
        var pendingInviteCode: String?
        @Shared(.appStorage("sessionId")) var sessionId: String? = ""

        init() {
            self.splash = .init()
            self.login = nil
            self.main = nil
            self.pendingInviteCode = nil
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
    }
    
    enum InnerAction {
        case setLoginState
        case setMainState
        case handleDeepLinkJoin(String)
        case setPendingInviteCode(String?)
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
            return .concatenate(
                .merge(
                    .cancel(id: CancelID.transitionToLogin),
                    .cancel(id: CancelID.transitionToMain)
                ),
                .send(.inner(.setLoginState))
            )

        case .presentMain:
            return .concatenate(
                .merge(
                    .cancel(id: CancelID.transitionToLogin),
                    .cancel(id: CancelID.transitionToMain)
                ),
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
            state.pendingInviteCode = nil
            state.main = .init(pendingInviteCode: inviteCode)
            state.splash = nil
            state.login = nil
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
                    // 로그인되어 있지 않으면 초대 코드를 저장하고 로그인 화면으로
                    await send(.inner(.setPendingInviteCode(inviteCode)))
                    await send(.view(.presentLogin))
                }
            }

        case .setPendingInviteCode(let code):
            state.pendingInviteCode = code
            return .none
        }
    }
    
    func handleScopeAction(
        _ state: inout State,
        action: ScopeAction
    ) -> Effect<Action> {
        switch action {
        case .splash(.delegate(.presentLogin)):
            return .run { send in
                await send(.view(.presentLogin))
            }
            .cancellable(id: CancelID.transitionToLogin, cancelInFlight: true)
            
        case .splash(.delegate(.presentMain)):
            return .run { send in
                await send(.view(.presentMain), animation: .easeIn)
            }
            .cancellable(id: CancelID.transitionToMain, cancelInFlight: true)
            
        case .login(.delegate(.presentMain)):
            return .run { send in
                await send(.view(.presentMain), animation: .easeIn)
            }
            .cancellable(id: CancelID.transitionToMain, cancelInFlight: true)
            
        case .main(.delegate(.presentLogin)):
            return .run { send in
                await send(.view(.presentLogin), animation: .interactiveSpring(
                    response: 0.5,
                    dampingFraction: 0.9,
                    blendDuration: 0.1
                ))
            }
            .cancellable(id: CancelID.transitionToLogin, cancelInFlight: true)
            
        default:
            return .none
        }
    }
}
