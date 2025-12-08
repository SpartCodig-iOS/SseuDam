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
import DesignSystem

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
        @Shared(.appStorage("socialType")) var socialType: SocialType? = nil
        @Shared(.appStorage("sessionId")) var sessionId: String? = ""

        @Presents var destination: Destination.State?

        // 약관 동의 후 회원가입을 위한 OAuth 데이터 임시 저장
        var pendingOAuthData: AuthData?

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

    @CasePathable
    public enum AsyncAction {
        case prepareAppleRequest(ASAuthorizationAppleIDRequest)
        case appleCompletion(Result<ASAuthorization, Error>)
        case signUpWithTermsAgreement(AuthData)
    }

    // MARK: - InnerAction (결과 처리만)
    public enum InnerAction {
        case authFlowResult(AuthFlowOutcome)
    }

    // MARK: - DelegateAction
    public enum DelegateAction: Equatable {
        case presentTravelList
        case presentTermsAgreement
        case presentServiceWeb
        case presentPrivacyWeb
    }

    // MARK: - Dependencies (하나로 통합!)

    @Dependency(UnifiedOAuthUseCase.self) var unifiedOAuthUseCase
    @Dependency(SessionUseCase.self) var sessionUseCase


    nonisolated enum CancelID: Hashable {
        case googleOAuth
        case appleOAuth
        case kakaoOAuth
        case session
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

extension LoginFeature.Destination.State: Hashable {}

extension LoginFeature.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(isLoading)
        hasher.combine(statusMessage)
        hasher.combine(authResult)
        hasher.combine(currentNonce)
        hasher.combine(destination)
        hasher.combine(pendingOAuthData)
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

            // 약관 동의 완료 후 저장된 OAuth 데이터로 회원가입 진행
            if let pendingData = state.pendingOAuthData {
                state.pendingOAuthData = nil
                return .send(.async(.signUpWithTermsAgreement(pendingData)))
            }

            return .send(.delegate(.presentTravelList))


          case .presented(.termsService(.delegate(.presentPrivacyWeb))):
            return .send(.delegate(.presentPrivacyWeb))

          case .presented(.termsService(.delegate(.presentServiceWeb))):
            return .send(.delegate(.presentServiceWeb))
            
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
        case .authFlowResult(let outcome):
            state.isLoading = false

            switch outcome {
            case .loginSuccess(let authEntity), .signUpSuccess(let authEntity):
                state.authResult = authEntity
                state.statusMessage = "\(authEntity.provider.rawValue) 인증 성공!"
                state.$sessionId.withLock { $0 = authEntity.token.sessionID }
                return .send(.delegate(.presentTravelList))

            case .needsTermsAgreement(let authData):
                state.pendingOAuthData = authData
                state.statusMessage = "약관 동의가 필요합니다"
                return .send(.delegate(.presentTermsAgreement))

            case .failure(let error):
                state.statusMessage = "인증 실패: \(error.localizedDescription)"

                // Toast로 에러 메시지 표시
                return .run { _ in
                    await MainActor.run {
                        ToastManager.shared.showError("인증에 실패했어요. 다시 시도해주세요.")
                    }
                }
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
            guard
                case .success(let auth) = result,
                let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                !state.currentNonce.isEmpty
            else {
                return .send(.inner(.authFlowResult(.failure(.invalidCredential("Apple 인증 정보가 없습니다")))))
            }

            return startOAuthFlow(
                state: &state,
                socialType: .apple,
                appleCredential: credential,
                nonce: state.currentNonce
            )

        case .signUpWithTermsAgreement(let oAuthData):
            state.isLoading = true
            state.statusMessage = "회원가입 중..."

            return .run { send in
                let result = await unifiedOAuthUseCase.signUpWithTermsAgreement(with: oAuthData)
                switch result {
                case .success(let authResult):
                    await send(.inner(.authFlowResult(.signUpSuccess(authResult))))
                case .failure(let error):
                    await send(.inner(.authFlowResult(.failure(error))))
                }
            }
            .cancellable(id: CancelID.googleOAuth, cancelInFlight: true)
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

          case .presentPrivacyWeb:
            return .none

          case .presentServiceWeb:
            return .none
        }
    }
}

// MARK: - Private Helpers

private extension LoginFeature {

    func startOAuthFlow(
        state: inout State,
        socialType: SocialType,
        appleCredential: ASAuthorizationAppleIDCredential? = nil,
        nonce: String? = nil
    ) -> Effect<Action> {
        state.isLoading = true
        state.statusMessage = "\(socialType.rawValue) 로그인 중..."

        let cancelID: CancelID
        switch socialType {
        case .google: cancelID = .googleOAuth
        case .apple: cancelID = .appleOAuth
        case .kakao: cancelID = .kakaoOAuth
        case .none: cancelID = .appleOAuth
        }

        return .run { send in
            let outcome = await unifiedOAuthUseCase.processOAuthFlow(
                with: socialType,
                appleCredential: appleCredential,
                nonce: nonce
            )
            await send(.inner(.authFlowResult(outcome)))
        }
        .cancellable(id: cancelID, cancelInFlight: true)
    }
}

// MARK: - Destination State Equatable
extension LoginFeature.Destination.State: Equatable {}
