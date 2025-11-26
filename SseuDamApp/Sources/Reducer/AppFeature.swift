//
//  AppFeature.swift
//  SseuDamApp
//
//  Created by Wonji Suh  on 11/19/25.
//

import ComposableArchitecture
import Data
import LoginFeature
import AuthenticationServices

@Reducer
struct AppFeature {

  // MARK: - State

  @ObservableState
  enum State: Equatable {
    case login(LoginFeature.State)
    // 나중에 메인 탭 추가하면:
    // case main(MainFeature.State)

    init() {
      self = .login(.init())
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
      LoginFeature()
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
      // 지금은 이미 login 상태라서 아무 것도 안 해도 됨
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
    }
  }
}

