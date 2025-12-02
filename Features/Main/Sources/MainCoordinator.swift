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
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(_, .travelList(.createButtonTapped))):
                state.routes.push(.createTravel(.init()))
                return .none
            case .router(.routeAction(_, .createTravel(.dismiss))):
                state.routes.pop()
                return .none
            case let .router(.routeAction(_, .travelList(.travelSelected(travelId)))):
                state.routes.push(.settlementCoordinator(.init(travelId: travelId)))
                return .none
            case .router(.routeAction(_, .settlementCoordinator(.delegate(.onTapBackButton)))):
                state.routes.pop()
                return .none
            case .router(.routeAction(_, .settlementCoordinator(.delegate(.onTapTravelSettingsButton(let travelId))))):
                print("\(travelId) 여행 설정 페이지로 넘어갑니다.")
                return .none
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
