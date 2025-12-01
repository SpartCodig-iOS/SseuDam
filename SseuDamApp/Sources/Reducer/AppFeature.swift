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
import TravelFeature
import Domain
@Reducer
struct AppFeature {

  // MARK: - State

  @ObservableState
  enum State: Equatable {
    case login(LoginCoordinator.State)
    case splash(SplashFeature.State)
    case travel(TravelListFeature.State)
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
    case travel(TravelListFeature.Action)
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
    .ifCaseLet(\.travel, action: \.scope.travel) {
      TravelListFeature()
    }
  }
}

extension AppFeature.State {
  var caseKey: String {
    switch self {
    case .splash: return "splash"
    case .login: return "login"
    case .travel: return "travel"
    case .profile: return "profile"
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
        return .none

    case .setMainState:
        state = .travel(.init())
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

      case .login(.delegate(.presentTravel)):
        return .run { send in
          await send(.view(.presentMain), animation: .easeIn)
        }
        .cancellable(id: CancelID.transitionToMain, cancelInFlight: true)

      case .travel(.presentToLogin):
        return .run { send in
          await send(.view(.presentLogin), animation: .interactiveSpring(
            response: 0.5,
            dampingFraction: 0.9,
            blendDuration: 0.1
          ))
        }
        .cancellable(id: CancelID.transitionToLogin, cancelInFlight: true)
        
      case .profile(.delegate(.presentLogin)):
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
