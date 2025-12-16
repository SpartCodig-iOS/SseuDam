//
//  SettlementFeature.swift
//  SettlementFeature
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import Domain
import ComposableArchitecture
import ExpenseListFeature
import SettlementResultFeature

@Reducer
public struct SettlementFeature {
    @Dependency(\.fetchTravelDetailUseCase) var fetchTravelDetailUseCase
    @Dependency(\.loadTravelDetailCacheUseCase) var loadTravelDetailCacheUseCase
    
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public let travelId: String
        @Shared public var travel: Travel?
        @Shared public var expenses: [Expense]
        public var travelTitle: String {
            return travel?.title ?? String()
        }
        public var selectedTab: Int = 0

        // Child States
        public var expenseList: ExpenseListFeature.State
        public var settlementResult: SettlementResultFeature.State

        public init(_ travelId: String) {
            self.travelId = travelId
            let travel = Shared<Travel?>(value: nil)
            let expenses = Shared<[Expense]>(value: [])
            self._travel = travel
            self._expenses = expenses
            self.expenseList = ExpenseListFeature.State(travelId: travelId, travel: travel, expenses: expenses)
            self.settlementResult = SettlementResultFeature.State(travelId: travelId, travel: travel, expenses: expenses)
        }
    }

    @CasePathable
    public enum Action: BindableAction, ViewAction {
        case binding(BindingAction<State>)

        case view(ViewAction)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)
        case delegate(DelegateAction)
        case navigateToExpense(String)
        case navigateToSettlement

        @CasePathable
        public enum ViewAction {
            case onAppear
            case backButtonTapped
            case settingsButtonTapped
            case tabSelected(Int)
        }
        
        @CasePathable
        public enum InnerAction {
            case cachedTravel(Travel)
            case travelDetailResponse(Result<Travel, Error>)
        }
        
        @CasePathable
        public enum AsyncAction {
            case fetchTravel
        }

        @CasePathable
        public enum DelegateAction {
            case onTapSettingsButton(travelId: String)
            case addExpenseButtonTapped
            case onTapExpense(Expense)
        }
        
        @CasePathable
        public enum ScopeAction {
            case expenseList(ExpenseListFeature.Action)
            case settlementResult(SettlementResultFeature.Action)
        }
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.expenseList, action: \.scope.expenseList) {
            ExpenseListFeature()
        }
        
        Scope(state: \.settlementResult, action: \.scope.settlementResult) {
            SettlementResultFeature()
        }

        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                return handleViewAction(state: &state, action: viewAction)
                
            case .inner(let innerAction):
                return handleInnerAction(state: &state, action: innerAction)
                
            case .async(let asyncAction):
                return handleAsyncAction(state: &state, action: asyncAction)
                
            case .scope(.expenseList(.delegate(.onTapAddExpense))):
                return .send(.delegate(.addExpenseButtonTapped))
                
            case let .scope(.expenseList(.delegate(.onTapExpense(expense)))):
                return .send(.delegate(.onTapExpense(expense)))
                
            case .scope:
                return .none
                
            case .binding:
                return .none
                
            case .delegate:
                return .none

            case .navigateToExpense(let expenseId):
                // 지출 목록 탭으로 이동 (index 0)
                state.selectedTab = 0
                return .send(.scope(.expenseList(.highlightExpense(expenseId))))

            case .navigateToSettlement:
                state.selectedTab = 1
                return .none
            }
        }
    }
}

extension SettlementFeature {
    // MARK: - View Action Handler
    private func handleViewAction(state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .send(.async(.fetchTravel))

        case .backButtonTapped:
            return .none

        case .settingsButtonTapped:
            return .send(.delegate(.onTapSettingsButton(travelId: state.travelId)))
            
        case .tabSelected(let index):
            state.selectedTab = index
            return .none
        }
    }
    
    // MARK: - Inner Action Handler
    private func handleInnerAction(state: inout State, action: Action.InnerAction) -> Effect<Action> {
        switch action {
        case let .cachedTravel(travel):
            state.$travel.withLock {
                $0 = travel
            }
            return .none

        case let .travelDetailResponse(.success(travel)):
            state.$travel.withLock {
                $0 = travel
            }

            return .none

        case let .travelDetailResponse(.failure(error)):
            print("Failed to fetch travel detail: \(error)")
            // TODO: Error handling
            return .none
        }
    }
    
    // MARK: - Async Action Handler
    private func handleAsyncAction(state: inout State, action: Action.AsyncAction) -> Effect<Action> {
        switch action {
        case .fetchTravel:
            let travelId = state.travelId
            return .run { send in
                if let cached = try? await loadTravelDetailCacheUseCase.execute(id: travelId) {
                    await send(.inner(.cachedTravel(cached)))
                }
                let result = await Result {
                    try await fetchTravelDetailUseCase.execute(id: travelId)
                }
                await send(.inner(.travelDetailResponse(result)))
            }
        }
    }
}
