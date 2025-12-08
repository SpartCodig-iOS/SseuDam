//
//  SettlementResultFeature.swift
//  SettlementResult
//
//  Created by 홍석현 on 12/5/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
public struct SettlementResultFeature {
    @Dependency(\.fetchSettlementUseCase) var fetchSettlementUseCase
    @Shared(.appStorage("userId")) var userId: String? = ""

    public init() {}

    @ObservableState
    public struct State: Equatable {
        public let travelId: String
        @Shared public var travel: Travel?
        @Shared public var expenses: [Expense]
        public var currentUserId: String?

        public var settlement: TravelSettlement?
        public var isLoading: Bool = false
        @Presents public var alert: AlertState<Action.AlertAction>?

        public var totalExpenseAmount: Int {
            Int(expenses.reduce(0) { $0 + $1.convertedAmount })
        }

        public var myExpenseAmount: Int {
            guard let userId = currentUserId else { return 0 }
            return Int(expenses
                .filter { $0.payerId == userId }
                .reduce(0) { $0 + $1.convertedAmount })
        }

        public var totalPersonCount: Int {
            guard let travel = travel else { return 0 }
            return travel.members.count
        }

        public var paymentsToMake: [Settlement] {
            guard let settlement = settlement else { return [] }
            // 내가 지급해야 하는 정산 (내가 fromMember인 경우)
            // TODO: 현재 사용자 ID 가져오기
            return settlement.recommendedSettlements.filter { $0.status == .pending }
        }

        public var paymentsToReceive: [Settlement] {
            guard let settlement = settlement else { return [] }
            // 내가 받아야 하는 정산 (내가 toMember인 경우)
            // TODO: 현재 사용자 ID 가져오기
            return settlement.recommendedSettlements.filter { $0.status == .pending }
        }

        public init(
            travelId: String,
            travel: Shared<Travel?>,
            expenses: Shared<[Expense]>
        ) {
            self.travelId = travelId
            self._travel = travel
            self._expenses = expenses
        }
    }

    @CasePathable
    public enum Action: BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case view(ViewAction)
        case inner(InnerAction)
        case async(AsyncAction)
        case scope(ScopeAction)

        @CasePathable
        public enum ViewAction {
            case onAppear
            case backButtonTapped
        }

        @CasePathable
        public enum InnerAction {
            case settlementResponse(Result<TravelSettlement, Error>)
        }

        @CasePathable
        public enum AsyncAction {
            case fetchData
        }

        @CasePathable
        public enum ScopeAction {
            case alert(PresentationAction<AlertAction>)
        }
        
        @CasePathable
        public enum AlertAction {
            case confirmTapped
        }
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                return handleViewAction(state: &state, action: viewAction)
            case .inner(let innerAction):
                return handleInnerAction(state: &state, action: innerAction)
            case .async(let asyncAction):
                return handleAsyncAction(state: &state, action: asyncAction)
            case .scope(let scopeAction):
                return handleScopeAction(state: &state, action: scopeAction)
            case .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.scope.alert)
    }
}

extension SettlementResultFeature {
    // MARK: - View Action Handler
    private func handleViewAction(state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .onAppear:
            state.currentUserId = userId
            return .send(.async(.fetchData))

        case .backButtonTapped:
            return .none
        }
    }

    // MARK: - Inner Action Handler
    private func handleInnerAction(state: inout State, action: Action.InnerAction) -> Effect<Action> {
        switch action {
        case let .settlementResponse(.success(settlement)):
            state.settlement = settlement
            state.isLoading = false
            return .none

        case let .settlementResponse(.failure(error)):
            state.isLoading = false
            state.alert = AlertState {
                TextState("오류")
            } actions: {
                ButtonState(action: .confirmTapped) {
                    TextState("확인")
                }
            } message: {
                TextState("정산 정보를 불러오는데 실패했습니다.\n\(error.localizedDescription)")
            }
            return .none
        }
    }

    // MARK: - Async Action Handler
    private func handleAsyncAction(state: inout State, action: Action.AsyncAction) -> Effect<Action> {
        switch action {
        case .fetchData:
            let travelId = state.travelId
            state.isLoading = true
            return .run { send in
                let settlementResult = await Result {
                    try await fetchSettlementUseCase.execute(travelId: travelId)
                }

                await send(.inner(.settlementResponse(settlementResult)))
            }
        }
    }

    // MARK: - Scope Action Handler
    private func handleScopeAction(state: inout State, action: Action.ScopeAction) -> Effect<Action> {
        switch action {
        case .alert:
            return .none
        }
    }
}
