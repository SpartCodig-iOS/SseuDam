//
//  MainCoordinator.swift
//  MainFeature
//
//  Created by 홍석현 on 11/30/25.
//

import Foundation
import TCACoordinators
import ComposableArchitecture
import SettlementFeature

@Reducer
public struct MainCoordinator {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var routes: [Route<Screen.State>]

        public init() {
            self.routes = [.root(.travelList(.init()), embedInNavigationView: true)]
        }
    }

    public enum Action {
        case router(IndexedRouterActionOf<Screen>)
        case delegate(DelegateAction)
    }


    public enum DelegateAction {
        case presentLogin
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .router(let routeAction):
                    return routerAction(state: &state, action: routeAction)

                case .delegate(let delegateAction):
                    return handleDelegateAction(state: &state, action: delegateAction)

            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}


extension MainCoordinator {
    private func routerAction(
        state: inout State,
        action: IndexedRouterActionOf<Screen>
    ) -> Effect<Action> {
        switch action {
            case .routeAction(_, .travelList(.createButtonTapped)):
                state.routes.push(.createTravel(.init()))
                return .none
            case .routeAction(_, .createTravel(.dismiss)):
                state.routes.pop()
                return .none

            case let .routeAction(_, .travelList(.travelSelected(travelId))):
                state.routes.push(.settlementCoordinator(.init(travelId: travelId)))
                return .none

            case .routeAction(id: _, action: .travelList(.profileButtonTapped)):
                state.routes.push(.profile(.init()))
                return .none

            case .routeAction(id: _, action: .profile(.delegate(.backToTravel))):
                state.routes.goBack()
                return .none

          case .routeAction(id: _, action: .profile(.delegate(.presentLogin))):
            return .send(.delegate(.presentLogin))

            default:
                return .none
        }
    }

    private func handleDelegateAction(
        state: inout State,
        action: DelegateAction
    ) -> Effect<Action> {
        switch action {
            case .presentLogin:
                return .none
        }
    }
}
