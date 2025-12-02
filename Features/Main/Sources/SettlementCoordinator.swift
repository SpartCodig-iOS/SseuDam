//
//  SettlementCoordinator.swift
//  MainFeature
//
//  Created by 홍석현 on 11/30/25.
//

import Foundation
import ComposableArchitecture
import TCACoordinators
import SettlementFeature
import ExpenseFeature
import TravelFeature

@Reducer
public struct SettlementCoordinator {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var routes: [Route<SettlementScreen.State>]
        let travelId: String

        public init(travelId: String) {
            self.travelId = travelId
            self.routes = [.root(.settlement(.init(travelId)))]
        }
    }

    public enum Action {
        case router(IndexedRouterActionOf<SettlementScreen>)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            // 지출 추가 버튼
            case .router(.routeAction(_, .settlement(.view(.addExpenseButtonTapped)))):
                guard let settlementState = state.routes.first?.screen.settlement,
                      let travel = settlementState.travel else {
                    return .none
                }
                state.routes.push(.expense(.init(travel: travel)))
                return .none
                
            case .router(.routeAction(_, .settlement(.view(.onTapExpense(let expense))))):
                guard let settlementState = state.routes.first?.screen.settlement,
                      let travel = settlementState.travel else {
                    return .none
                }
                state.routes.push(.expense(.init(travel: travel, expense: expense)))
                return .none

            // 설정 버튼 (여행 상세/수정) - 추후 구현
             case .router(.routeAction(_, .expense(.delegate(.finishSaveExpense)))):
                 state.routes.pop()
                 return .none

            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
