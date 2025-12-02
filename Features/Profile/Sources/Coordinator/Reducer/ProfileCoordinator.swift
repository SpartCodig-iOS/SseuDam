//
//  ProfileCoordinator.swift
//  ProfileFeature
//
//  Created by Wonji Suh  on 12/1/25.
//


import ComposableArchitecture
import TCACoordinators


@Reducer
public struct ProfileCoordinator {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var routes: [Route<ProfileScreen.State>]
    public init() {
      self.routes = [.root(.profile(.init()), embedInNavigationView: true)]
    }
  }

  public enum Action {
    case router(IndexedRouterActionOf<ProfileScreen>)
    case view(View)
    case delegate(DelegateAction)
    case scope(ScopeAction)
  }

  @CasePathable
  public enum View {
    case backAction
    case backToRootAction
  }

  @CasePathable
  public enum DelegateAction {
    case presentLogin
    case backToTravel

  }

  @CasePathable
  public enum ScopeAction {
//    case login(LoginFeature.Action)
  }

  nonisolated enum CancelID: Hashable {
      case coordinator
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
        case .router(let routeAction):
          return routerAction(state: &state, action: routeAction)

        case .view(let viewAction):
          return handleViewAction(state: &state, action: viewAction)

        case .scope(let scopeAction):
          return handleScopeAction(state: &state, action: scopeAction)

        case .delegate(let navigationAction):
            return handleDelegateAction(state: &state, action: navigationAction)
      }
    }
    .forEachRoute(\.routes, action: \.router, cancellationId: CancelID.coordinator)
  }
}

extension ProfileCoordinator {
  @Reducer(state: .equatable)
  public enum ProfileScreen {
    case profile(ProfileFeature)
  }
}


extension ProfileCoordinator {
  private func routerAction(
    state: inout State,
    action: IndexedRouterActionOf<ProfileScreen>
  ) -> Effect<Action> {
    switch action {
      case .routeAction(id: _, action: .profile(.delegate(.presentLogin))):
        return .send(.delegate(.presentLogin))

      case .routeAction(id: _, action: .profile(.delegate(.backToTravel))):
        return .send(.delegate(.backToTravel))
      default:
        return .none
    }
  }

  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .backAction:
      state.routes.goBack()
      return .none

    case .backToRootAction:
      return .routeWithDelaysIfUnsupported(state.routes, action: \.router) {
        $0.goBackToRoot()
      }
    }
  }

  private func handleDelegateAction(
      state: inout State,
      action: DelegateAction
  ) -> Effect<Action> {
      switch action {
        case .presentLogin:
          return .none

        case .backToTravel:
          return .none
      }
  }

  private func handleScopeAction(
      state: inout State,
      action: ScopeAction
  ) -> Effect<Action> {
      switch action {
        default:
          return .none
      }
  }
}
