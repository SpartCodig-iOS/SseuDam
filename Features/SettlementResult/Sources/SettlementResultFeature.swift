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
    @Dependency(\.calculateSettlementUseCase) var calculateSettlementUseCase
    @Shared(.appStorage("userId")) var userId: String? = ""

    public init() {}

    @ObservableState
    public struct State: Equatable {
        public let travelId: String
        @Shared public var travel: Travel?
        @Shared public var expenses: [Expense]
        public var currentUserId: String?

        @Presents public var alert: AlertState<Action.AlertAction>?

        // 정산 계산 결과
        public var settlementCalculation: SettlementCalculation = SettlementCalculation(
            totalExpenseAmount: 0,
            myShareAmount: 0,
            totalPersonCount: 0,
            averagePerPerson: 0,
            myNetBalance: 0,
            paymentsToMake: [],
            paymentsToReceive: [],
            memberDetails: []
        )

        // 총 지출 금액
        public var totalExpenseAmount: Int {
            Int(settlementCalculation.totalExpenseAmount)
        }

        // 내 부담 금액 (내가 실제로 부담해야 할 금액)
        public var myExpenseAmount: Int {
            Int(settlementCalculation.myShareAmount)
        }

        // 인원수
        public var totalPersonCount: Int {
            settlementCalculation.totalPersonCount
        }

        // 지급 예정 금액
        public var paymentsToMake: [PaymentInfo] {
            settlementCalculation.paymentsToMake
        }

        // 수령 예정 금액
        public var paymentsToReceive: [PaymentInfo] {
            settlementCalculation.paymentsToReceive
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
        case scope(ScopeAction)

        @CasePathable
        public enum ViewAction {
            case onAppear
            case backButtonTapped
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
            case .view(.onAppear):
                state.currentUserId = userId
                // 정산 계산
                if let travel = state.travel {
                    state.settlementCalculation = calculateSettlementUseCase.execute(
                        expenses: state.expenses,
                        members: travel.members,
                        currentUserId: state.currentUserId
                    )
                }
                return .none

            case .view(.backButtonTapped):
                return .none

            case .scope, .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.scope.alert)
    }
}
