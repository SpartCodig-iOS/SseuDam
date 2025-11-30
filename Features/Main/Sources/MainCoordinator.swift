//
//  MainCoordinator.swift
//  MainFeature
//
//  Created by 홍석현 on 11/30/25.
//

import Foundation
import TCACoordinators
import ComposableArchitecture

@Reducer
public struct MainCoordinator {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var routes: [Route<Screen.State>]

        public init(routes: [Route<Screen.State>] = [.root(.travelList(.init()))]) {
            self.routes = routes
        }
    }

    public enum Action {
        case router(IndexedRouterActionOf<Screen>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            // TravelList에서 새 여행 추가 버튼
            case .router(.routeAction(_, .travelList(.createButtonTapped))):
                state.routes.presentSheet(.createTravel(.init()), embedInNavigationView: true)
                return .none

            // TravelList에서 여행 선택
            case let .router(.routeAction(_, .travelList(.travelSelected(travelId)))):
                state.routes.push(.settlementCoordinator(.init(travelId: travelId)))
                return .none

            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
