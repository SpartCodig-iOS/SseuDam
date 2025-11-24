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

        public init() {}
    }

    // MARK: - Action

    public enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case view(View)
        case async(AsyncAction)
        case inner(InnerAction)
        case navigation(NavigationAction)
    }

    // MARK: - ViewAction
    @CasePathable
    public enum View {
        case googleButtonTapped
        case signInWithSocial(social: SocialType)
    }

    // MARK: - AsyncAction (비동기 처리 트리거)
    public enum AsyncAction {
        case prepareAppleRequest(ASAuthorizationAppleIDRequest)
        case googleSignIn
        case appleSignIn(Result<AppleLoginPayload, AuthError>)
        case appleCompletion(Result<ASAuthorization, Error>)
        case checkSignUpUser
    }

    // MARK: - InnerAction (비동기 결과 처리)
    public enum InnerAction {
        case googleLoginResponse(Result<UserEntity, AuthError>)
        case appleLoginResponse(Result<UserEntity, AuthError>)
        case checkUserResponse(Result<OAuthCheckUser, AuthError>)
    }

    // MARK: - NavigationAction
    public enum NavigationAction: Equatable {
    }

    // MARK: - Dependencies

    @Dependency(LoginUseCase.self) var loginUseCase
    @Dependency(\.continuousClock) var clock

    // MARK: - Body

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case .binding:
                    return .none

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
    }
}

// MARK: - Handlers

extension LoginFeature {
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

                            try await clock.sleep(for: .seconds(0.04))
                            await send(.async(.checkSignUpUser))
                        }

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
                                // 여기에는 로그인 로직
                            } else {
                                // 여기에는 회원가입 로직
                            }

                        case .failure(let error):
                            await send(.inner(.checkUserResponse(.failure(.unknownError(error.localizedDescription)))))
                    }
                }
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
        }
    }
}
