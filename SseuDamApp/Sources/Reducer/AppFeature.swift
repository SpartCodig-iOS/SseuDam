//
//  AppFeature.swift
//  SseuDamApp
//
//  Created by Wonji Suh  on 11/19/25.
//

import ComposableArchitecture
import LoginFeature
import MainFeature

@Reducer
struct AppFeature {

  // MARK: - State

  @ObservableState
  enum State: Equatable {
    case login(LoginFeature.State)
    case main(MainCoordinator.State)

    init() {
      self = .main(.init())
    }
  }

  // MARK: - Action

  enum Action: ViewAction {
    case view(View)
    case scope(ScopeAction)
  }

  @CasePathable
  enum View {
    case presentLogin
    case presentMain
  }

  @CasePathable
  enum ScopeAction {
    case login(LoginFeature.Action)
    case main(MainCoordinator.Action)
  }

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
      LoginFeature()
    }
    .ifCaseLet(\.main, action: \.scope.main) {
      MainCoordinator()
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
      state = .login(.init())
      return .none

    case .presentMain:
      state = .main(.init())
      return .none
    }
  }

  func handleScopeAction(
    _ state: inout State,
    action: ScopeAction
  ) -> Effect<Action> {
    switch action {
    case .login(.delegate(.presentTravelList)):
      // 로그인 성공 시 메인 화면으로 전환
      return .send(.view(.presentMain))

    case .login:
      return .none

    case .main:
      return .none
    }
  }
}

