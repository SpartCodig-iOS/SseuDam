//
//  SplashFeature.swift
//  SplashFeature
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation
import ComposableArchitecture
import Domain

@Reducer
public struct SplashFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var isAnimated: Bool = false
        var errorMessage: String? = ""
        @Shared(.appStorage("sessionId")) var sessionId: String? = ""
        @Shared(.appStorage("socialType"))  var socialType: SocialType? = nil
        var sessionResult : SessionStatus?

        public init() {}
    }

    public enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case view(View)
        case async(AsyncAction)
        case inner(InnerAction)
        case delegate(DelegateAction)

    }

    //MARK: - ViewAction
    @CasePathable
    public enum View {
        case onAppear
        case startAnimation
        case animationCompleted
    }



    //MARK: - AsyncAction 비동기 처리 액션
    public enum AsyncAction: Equatable {
        case checkSession
    }

    //MARK: - 앱내에서 사용하는 액션
    public enum InnerAction: Equatable {
        case checkSessionResponse(Result<SessionStatus, AuthError>)
    }

    //MARK: - NavigationAction
    public enum DelegateAction: Equatable {
        case presentMain
        case presentLogin

    }

    nonisolated enum CancelID: Hashable {
        case session
    }

    @Dependency(SessionUseCase.self) var sessionUseCase
    @Dependency(\.continuousClock) var clock

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case .binding(_):
                    return .none

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
    }
}

extension SplashFeature {
    private func handleViewAction(
        state: inout State,
        action: View
    ) -> Effect<Action> {
        switch action {
            case .onAppear:
            return .run {  [sessionId = state.sessionId] send in
              guard let sessionId = sessionId, !sessionId.isEmpty else {
                await send(.delegate(.presentLogin))
                return
              }
              await send(.async(.checkSession))
            }

            case .startAnimation:
                return .run { send in
                    try await Task.sleep(for: .seconds(0.8))
                    await send(.view(.animationCompleted))
                }

            case .animationCompleted:
                state.isAnimated = true
                return .send(.view(.onAppear))
        }
    }

    private func handleAsyncAction(
        state: inout State,
        action: AsyncAction
    ) -> Effect<Action> {
        switch action {
            case .checkSession:
                return .run { [sessionId = state.sessionId] send in
                    let result = await Result {
                        try await sessionUseCase.checkSession(sessionId: sessionId ?? "")
                    }
                        .mapError { error -> AuthError in
                            if let authError = error as? AuthError {
                                return authError
                            } else {
                                return .unknownError(error.localizedDescription)
                            }
                        }
                    await send(.inner(.checkSessionResponse(result)))
                }
                .cancellable(id: CancelID.session, cancelInFlight: true)
        }
    }

    private func handleDelegateAction(
        state: inout State,
        action: DelegateAction
    ) -> Effect<Action> {
        switch action {
            case .presentMain:
                return .none
            case .presentLogin:
                return .none
        }
    }

    private func handleInnerAction(
        state: inout State,
        action: InnerAction
    ) -> Effect<Action> {
        switch action {
            case .checkSessionResponse(let result):
                switch result {
                    case .success(let sessionData):
                        state.sessionResult = sessionData
                        state.$sessionId.withLock { $0 = sessionData.sessionId }
                        state.$socialType.withLock { $0 = sessionData.provider }
                        return .concatenate(
                            .run { _ in try await clock.sleep(for: .seconds(1)) },
                            .send(.delegate(.presentMain))
                        )
                    case .failure(let error):
                        state.$socialType.withLock { $0 = nil }
                        state.errorMessage = "세션 조회 실패 : \(error.localizedDescription)"
                        return .send(.delegate(.presentLogin))
                }
        }
    }
}

