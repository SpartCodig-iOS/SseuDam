//
//  AppFeature.swift
//  SseuDamApp
//
//  Created by Wonji Suh  on 11/19/25.
//

import ComposableArchitecture
import Data
import LoginFeature
import SplashFeature

@Reducer
struct AppFeature {

  // MARK: - State

  @ObservableState
  enum State: Equatable {
    case login(LoginCoordinator.State)
    case splash(SplashFeature.State)
    // 나중에 메인 탭 추가하면:
    // case main(MainFeature.State)

    init() {
      self = .splash(.init())
    }
  }

  // MARK: - Action

  enum Action: ViewAction {
    case view(View)
    case inner(InnerAction)
    case scope(ScopeAction)
  }

  @CasePathable
  enum View {
    case presentLogin
    case presentMain
  }

  enum InnerAction {
    case setLoginState
    case setMainState
  }

  @CasePathable
  enum ScopeAction {
    case login(LoginCoordinator.Action)
    case splash(SplashFeature.Action)
  }

  @Dependency(\.continuousClock) var clock

  nonisolated enum CancelID: Hashable {
    case transitionToLogin
    case transitionToMain
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
    .ifCaseLet(\.login, action: \.scope.login) {
      LoginCoordinator()
    }
    .ifCaseLet(\.splash, action: \.scope.splash) {
      SplashFeature()
    }
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
    }
  }

  func handleInnerAction(
    _ state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case .setLoginState:
      state = .login(.init())
      // login view 로드 전에 바로 checkSession 실행
        return .none

    case .setMainState:
      // 추후 main 탭 상태로 전환 로직 작성
      // state = .main(MainFeature.State())
      return .none
    }
  }

  func handleScopeAction(
    _ state: inout State,
    action: ScopeAction
  ) -> Effect<Action> {
    switch action {
    case .login:
      return .none

      case .splash(.delegate(.presentLogin)):
        return .run { send in
          try await clock.sleep(for: .seconds(1))
          await send(.view(.presentLogin))
        }
        .cancellable(id: CancelID.transitionToLogin, cancelInFlight: true)

      case .splash(.delegate(.presentMain)):
        return .run { send in
          try await clock.sleep(for: .seconds(1))
          await send(.view(.presentLogin))
        }
        .cancellable(id: CancelID.transitionToMain, cancelInFlight: true)

      default:
        return .none
    }
  }
}

