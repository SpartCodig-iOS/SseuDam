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

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        var isLoading = false
        var statusMessage: String?
        var currentNonce: String?
        var userEntity: UserEntity?
        var checkUser: OAuthCheckUser?
        var authUserEntity: AuthEntity?
        @Presents var destination: Destination.State?

        public init() {}
    }

    // MARK: - Action

    public enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case view(View)
        case async(AsyncAction)
        case inner(InnerAction)
        case navigation(NavigationAction)
    }

    @Reducer
    public enum Destination {
      case termsService(TermsAgreementFeature)
    }


    // MARK: - ViewAction
    @CasePathable
    public enum View {
        case googleButtonTapped
        case signInWithSocial(social: SocialType)
        case appearModal
    }

    // MARK: - AsyncAction (비동기 처리 트리거)
    public enum AsyncAction {
        case checkSignUpUser
        case prepareAppleRequest(ASAuthorizationAppleIDRequest)
        case googleSignIn
        case appleSignIn(Result<AppleLoginPayload, AuthError>)
        case appleCompletion(Result<ASAuthorization, Error>)
        case checkSignUpUser
        case loginUser
        case signUpUser
    }

    // MARK: - InnerAction (비동기 결과 처리)
    public enum InnerAction {
        case googleLoginResponse(Result<UserEntity, AuthError>)
        case appleLoginResponse(Result<UserEntity, AuthError>)
        case checkUserResponse(Result<OAuthCheckUser, AuthError>)
        case authUserResponse(Result<AuthEntity, AuthError>)
    }

    // MARK: - NavigationAction
    public enum NavigationAction: Equatable {
    }

    // MARK: - Dependencies

    nonisolated enum CancelID: Hashable {
        case googleSignUp
        case appleSignUp
        case checkSignUpUser
        case loginUser
        case signUpUser
    }

    @Dependency(LoginUseCase.self) var loginUseCase
    @Dependency(SignUpUseCase.self) var signUpUseCase

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

                case .navigation(let navigationAction):
                    return handleNavigationAction(state: &state, action: navigationAction)
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
          case .presented(.termsService(.scope(.closeModel))):
              state.destination = nil
              return .send(.async(.signUpUser))
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
                // Google 버튼 탭
            case .googleButtonTapped:
                state.isLoading = true
                state.statusMessage = nil

                return .run { send in
                    await send(.async(.googleSignIn))
                }

            case .signInWithSocial(let social):
                return .run { send in
                    switch social {
                        case .google:
                            await send(.view(.googleButtonTapped))
                        default:
                            break
                    }
                }

            case .appearModal:
                state.destination = .termsService(.init())
                return .none
        }
    }

    // MARK: AsyncAction 처리 (실제 비동기 작업 실행)

    private func handleAsyncAction(
        state: inout State,
        action: AsyncAction
    ) -> Effect<Action> {
        switch action {
            case .prepareAppleRequest(let request):
                let nonce = AppleLoginManager().prepare(request)
                state.currentNonce = nonce
                return .none

            case .checkSignUpUser:
                return .run { [userEntity = state.userEntity] send in
                    let checkSignUpUserResult = await Result {
                        try await signUpUseCase.checkUserSignUp(accessToken: userEntity?.tokens.authToken ?? "", socialType: userEntity?.provider ?? .none)
                    }

                    switch checkSignUpUserResult {
                        case .success(let checkSignUpUserData):
                            await send(.inner(.checkUserResponse(.success(checkSignUpUserData))))

                            if checkSignUpUserData.registered == true {
                                // 여기에는 로그인 로직
                            } else {
                                // 여기에는 회원가입 로직
                            }

                        case .failure(let error):
                            await send(.inner(.checkUserResponse(.failure(.unknownError(error.localizedDescription)))))
                    }
                }

            case .googleSignIn:
                return .run { send in
                    do {
                        let user = try await loginUseCase.signUp(with: .google)
                        await send(.inner(.googleLoginResponse(.success(user))))
                        try await clock.sleep(for: .seconds(0.04))
                        await send(.async(.checkSignUpUser))
                    } catch let authError as AuthError {
                        await send(.inner(.googleLoginResponse(.failure(authError))))
                    } catch {
                        await send(.inner(.googleLoginResponse(
                            .failure(.unknownError(error.localizedDescription))
                        )))
                    }
                }
                .cancellable(id: CancelID.googleSignUp, cancelInFlight: true)

            case .appleSignIn(let result):
                switch result {
                    case let .success(payload):
                        return .run { send in
                            do {
                                let user = try await loginUseCase.signInWithApple(
                                    credential: payload.credential,
                                    nonce: payload.nonce
                                )
                                await send(.inner(.appleLoginResponse(.success(user))))
                            } catch let authError as AuthError {
                                await send(.inner(.appleLoginResponse(.failure(authError))))
                            } catch {
                                await send(.inner(.appleLoginResponse(
                                    .failure(.unknownError(error.localizedDescription))
                                )))
                            }
                        }
                        

                    case let .failure(error):
                        state.isLoading = false
                        state.statusMessage = error.localizedDescription
                        return .none
                }

            case .appleCompletion(let result):
                switch result {
                    case let .success(authorization):
                        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                            state.statusMessage = "Apple 인증 실패: 잘못된 자격 증명"
                            return .none
                        }

                        guard let nonce = state.currentNonce else {
                            state.statusMessage = "Apple 로그인 실패: nonce가 없습니다"
                            return .none
                        }

                        let payload = AppleLoginPayload(
                            credential: credential,
                            nonce: nonce
                        )

                        state.isLoading = true
                        state.statusMessage = nil

                        return .run { send in
                            await send(.async(.appleSignIn(.success(payload))))
                            await send(.async(.checkSignUpUser))
                        }
                        .cancellable(id: CancelID.appleSignUp, cancelInFlight: true)

                    case let .failure(error):
                        // 취소는 조용히 무시
                        if (error as NSError).code == ASAuthorizationError.canceled.rawValue {
                            return .none
                        } else {
                            let authError: AuthError = .unknownError(error.localizedDescription)
                            return .run { send in
                                await send(.async(.appleSignIn(.failure(authError))))
                            }
                        }
                }

            case .checkSignUpUser:
                return .run { [userEntity = state.userEntity] send in
                    let checkSignUpUserResult = await Result {
                        try await loginUseCase.checkUserSignUp(accessToken: userEntity?.tokens.authToken ?? "", socialType: userEntity?.provider ?? .none)
                    }

                    switch checkSignUpUserResult {
                        case .success(let checkSignUpUserData):
                            await send(.inner(.checkUserResponse(.success(checkSignUpUserData))))

                            if checkSignUpUserData.registered == true {
                                await send(.async(.loginUser))
                            } else {
                                await send(.view(.appearModal))
                            }

                        case .failure(let error):
                            await send(.inner(.checkUserResponse(.failure(.unknownError(error.localizedDescription)))))
                    }
                }
                .cancellable(id: CancelID.checkSignUpUser, cancelInFlight: true)

            case .loginUser:
                return .run {  [userEntity = state.userEntity] send in
                    let loginUserResult = await Result {
                        try await loginUseCase.loginUser(accessToken: userEntity?.tokens.authToken ?? "", socialType: userEntity?.provider ?? .none)
                    }

                    switch loginUserResult {

                        case .success(let loginUserData):
                            await send(.inner(.authUserResponse(.success(loginUserData))))

                        case .failure(let error):
                            await send(.inner(.authUserResponse(.failure(.unknownError(error.localizedDescription)))))
                    }
                }
                .cancellable(id: CancelID.loginUser, cancelInFlight: true)

            case .signUpUser:
                return .run {  [userEntity = state.userEntity] send in
                    let signUpUserResult = await Result {
                        try await loginUseCase.signUpUser(
                            accessToken: userEntity?.tokens.authToken ?? "",
                            socialType: userEntity?.provider ?? .none,
                            authCode: userEntity?.authCode ?? ""
                        )
                    }

                    switch signUpUserResult {
                        case .success(let signUpUserData):
                            await send(.inner(.authUserResponse(.success(signUpUserData))))
                        case .failure(let error):
                            await send(.inner(.authUserResponse(.failure(.unknownError(error.localizedDescription)))))
                    }
                }
                .cancellable(id: CancelID.signUpUser, cancelInFlight: true)
        }
    }

    // MARK: NavigationAction

    private func handleNavigationAction(
        state: inout State,
        action: NavigationAction
    ) -> Effect<Action> {
        switch action {
        }
    }

    // MARK: InnerAction (비동기 결과를 상태에 반영)

    private func handleInnerAction(
        state: inout State,
        action: InnerAction
    ) -> Effect<Action> {
        switch action {
            case .googleLoginResponse(let result):
                state.isLoading = false
                switch result {
                    case .success(let user):
                        state.userEntity = user
                        state.statusMessage = "Google 로그인 성공! 사용자: \(user.displayName ?? user.email ?? user.id)"
                    case .failure(let error):
                        state.statusMessage = "Google 로그인 실패: \(error.localizedDescription)"
                }
                return .none

            case .appleLoginResponse(let result):
                state.isLoading = false
                switch result {
                    case  .success(let user):
                        state.userEntity = user
                        state.statusMessage = "Apple 로그인 성공! 사용자: \(user.displayName ?? user.email ?? user.id)"
                    case  .failure(let error):
                        state.statusMessage = "Apple 로그인 실패: \(error.localizedDescription)"
                }
                return .none

            case .checkUserResponse(let result):
                switch result {
                    case .success(let checkUserData):
                        state.checkUser = checkUserData
                    case .failure(let error):
                        state.statusMessage = "\(error.errorDescription)"
                }
                return .none

            case .authUserResponse(let result):
                switch result {
                    case .success(let authModel):
                        state.authUserEntity = authModel
                        state.statusMessage = "\(authModel.provider) 로그인 및 회원가입 성공 "
                        let accessToken = authModel.token.accessToken
                        let refreshToken = authModel.token.refreshToken ?? ""
                        let authToken = state.userEntity?.tokens.authToken ?? ""
                        let updateModel = AuthEntity(
                            name: authModel.name,
                            provider: authModel.provider,
                            token: AuthTokens(
                                authToken: authToken,
                                accessToken: accessToken,
                                refreshToken: refreshToken,
                                sessionID: authModel.token.sessionID
                            )
                        )

                        state.authUserEntity = updateModel

                        KeychainManager.shared.saveTokens(accessToken: accessToken, refreshToken: refreshToken)
                        let tokens = KeychainManager.shared.loadTokens()
                        Log.debug("keychan", tokens)

                    case .failure(let error):
                        state.statusMessage = "\(error.errorDescription)"
                }
                return .none
        }
    }
}

// MARK: - Destination State Equatable
extension LoginFeature.Destination.State: Equatable {}
