//
//  SettlementCoordinator.swift
//  MainFeature
//
//  Created by 홍석현 on 11/30/25.
//

import Foundation
import ComposableArchitecture
import TCACoordinators
import ExpenseFeature

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
    
    @CasePathable
    public enum Action {
        case router(IndexedRouterActionOf<SettlementScreen>)
        case delegate(DelegateAction)
        
        @CasePathable
        public enum DelegateAction {
            case onTapBackButton
            case onTapTravelSettingsButton(travelId: String)
        }
    }
    
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            // 지출 추가 버튼
            case .router(.routeAction(_, .settlement(.delegate(.addExpenseButtonTapped)))):
                guard let settlementState = state.routes.first?.screen.settlement,
                      let travel = settlementState.travel else {
                    return .none
                }
                state.routes.push(.saveExpense(.init(travel: travel)))
                return .none
                
            case .router(.routeAction(_, .settlement(.delegate(.onTapExpense(let expense))))):
                guard let settlementState = state.routes.first?.screen.settlement,
                      let travel = settlementState.travel else {
                    return .none
                }
                state.routes.push(.saveExpense(.init(travel: travel, expense: expense)))
                return .none
                
            case .router(.routeAction(_, .settlement(.view(.backButtonTapped)))):
                return .send(.delegate(.onTapBackButton))
                
            case .router(.routeAction(_, .settlement(.delegate(.onTapSettingsButton(let travelId))))):
                return .send(.delegate(.onTapTravelSettingsButton(travelId: travelId)))

            // 설정 버튼 (여행 상세/수정) - 추후 구현
             case .router(.routeAction(_, .saveExpense(.delegate(.finishSaveExpense)))):
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
