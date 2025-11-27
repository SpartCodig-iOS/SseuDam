//
//  LoginFeature.swift
//  LoginFeature
//
//  Created by Wonji Suh  on 11/18/25.
//

import Foundation
import ComposableArchitecture
import Domain
import AuthenticationServices
import LogMacro

@Reducer
public struct LoginFeature {
    public init() {}

    // MARK: - State (간소화)

    @ObservableState
    public struct State: Equatable {
        var isLoading = false
        var statusMessage: String?
        var authResult: AuthResult?
        var currentNonce: String = ""
        @Presents var destination: Destination.State?

        public init() {}
      
    }

    // MARK: - Action (간소화)

    public enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case view(View)
        case async(AsyncAction)
        case inner(InnerAction)
        case delegate(DelegateAction)
    }

    @Reducer
    public enum Destination {
      case termsService(TermsAgreementFeature)
    }


    // MARK: - ViewAction
    @CasePathable
    public enum View {
        case googleButtonTapped
        case appleButtonTapped
        case signInWithSocial(social: SocialType)
    }

    public enum AsyncAction {
        case prepareAppleRequest(ASAuthorizationAppleIDRequest)
        case appleCompletion(Result<ASAuthorization, Error>)
    }

    // MARK: - InnerAction (결과 처리만)
    public enum InnerAction {
        case oAuthResult(Result<AuthResult, AuthError>)
    }

    // MARK: - DelegateAction
    public enum DelegateAction: Equatable {
        case presentTravelList
        case presentTermsAgreement
    }

    // MARK: - Dependencies (하나로 통합!)

    @Dependency(\.unifiedOAuthUseCase) var unifiedOAuthUseCase

    nonisolated enum CancelID: Hashable {
        case googleOAuth
        case appleOAuth
    }

    // MARK: - Body

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .destination(let action):
                return handleDestinationAction(state: &state, action: action)

            case .view(let viewAction):
                return handleViewAction(state: &state, action: viewAction)

            case .async(let asyncAction):
                return handleAsyncAction(state: &state, action: asyncAction)

            case .inner(let innerAction):
                return handleInnerAction(state: &state, action: innerAction)

            case .delegate(let navigationAction):
                return handleDelegateAction(state: &state, action: navigationAction)
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

// MARK: - Handlers

extension LoginFeature {

    private func handleDestinationAction(
        state: inout State,
        action: PresentationAction<Destination.Action>
    ) -> Effect<Action> {
        switch action {
        case .presented(.termsService(.scope(.close))):
            state.destination = nil
            return .send(.delegate(.presentTravelList))
        default:
            return .none
        }
    }

    // MARK: ViewAction 처리 (버튼/뷰 이벤트)
    private func handleViewAction(
        state: inout State,
        action: View
    ) -> Effect<Action> {
        switch action {
        case .googleButtonTapped:
            return startOAuthFlow(state: &state, socialType: .google)

        case .appleButtonTapped:
            return .none

        case .signInWithSocial(let social):
            if social == .apple {
                return .none
            }
            return startOAuthFlow(state: &state, socialType: social)
        }
    }


    private func handleInnerAction(
        state: inout State,
        action: InnerAction
    ) -> Effect<Action> {
        switch action {
        case .oAuthResult(let result):
            state.isLoading = false

            switch result {
            case .success(let authEntity):
                state.authResult = authEntity
                state.statusMessage = "\(authEntity.provider.rawValue) 인증 성공!"
                Log.info("🎉 OAuth authentication completed successfully")

                // 인증 완료 - 메인 화면으로 이동
                return .send(.delegate(.presentTravelList))

            case .failure(let error):
                state.statusMessage = "인증 실패: \(error.localizedDescription)"
                Log.error("❌ OAuth authentication failed: \(error)")
                return .none
            }
        }
    }

    private func handleAsyncAction(
        state: inout State,
        action: AsyncAction
    ) -> Effect<Action> {
        switch action {
          case .prepareAppleRequest(let request):
            let nonce = AppleLoginManager().prepare(request)
            state.currentNonce = nonce
            return .none

        case .appleCompletion(let result):
            state.isLoading = true
            state.statusMessage = "\(SocialType.apple.rawValue) 로그인 중..."
            return .run { [nonce = state.currentNonce] send in
                guard
                    case .success(let auth) = result,
                    let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                    !nonce.isEmpty
                else {
                    await send(.inner(.oAuthResult(.failure(.invalidCredential("Apple 인증 정보가 없습니다")))))
                    return
                }

                let loginResult = await unifiedOAuthUseCase.loginOrSignUp(
                    with: .apple,
                    appleCredential: credential,
                    nonce: nonce
                )
                await send(.inner(.oAuthResult(loginResult)))
            }
            .cancellable(id: CancelID.appleOAuth, cancelInFlight: true)
        }
    }

    private func handleDelegateAction(
        state: inout State,
        action: DelegateAction
    ) -> Effect<Action> {
        switch action {
        case .presentTravelList:
            return .none

        case .presentTermsAgreement:
            state.destination = .termsService(.init())
            return .none
        }
    }
}

// MARK: - Private Helpers

private extension LoginFeature {

    func startOAuthFlow(
        state: inout State,
        socialType: SocialType
    ) -> Effect<Action> {
        state.isLoading = true
        state.statusMessage = "\(socialType.rawValue) 로그인 중..."

        let cancelID: CancelID = socialType == .google ? .googleOAuth : .appleOAuth

        return .run { send in
            let result = await unifiedOAuthUseCase.loginOrSignUp(with: socialType)
            await send(.inner(.oAuthResult(result)))
        }
        .cancellable(id: cancelID, cancelInFlight: true)
    }
}

// MARK: - Destination State Equatable
extension LoginFeature.Destination.State: Equatable {}
