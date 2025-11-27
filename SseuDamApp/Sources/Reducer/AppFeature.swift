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
    case scope(ScopeAction)
  }

  @CasePathable
  enum View {
    case appearSession
    case presentLogin
    case presentMain
  }

  @CasePathable
  enum ScopeAction {
    case login(LoginCoordinator.Action)
    case splash(SplashFeature.Action)
    // case main(MainFeature.Action)
  }

  @Dependency(\.continuousClock) var clock

  // MARK: - body

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(let viewAction):
        return handleViewAction(&state, action: viewAction)

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
      case .appearSession:
        return .send(.scope(.login(.view(.onAppear))))

    case .presentLogin:
        state = .login(.init())
      return .none

    case .presentMain:
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
          await send(.view(.appearSession))
          try await clock.sleep(for: .seconds(0.5))
          await send(.view(.presentLogin))
        }

      case .splash(.delegate(.presentMain)):
        return .run { send in
          await send(.view(.appearSession))
          try await clock.sleep(for: .seconds(0.5))
          await send(.view(.presentLogin))
        }


      default:
        return .none

    }
  }
}

