//
//  SettlementResultFeature.swift
//  SettlementResult
//
//  Created by 홍석현 on 12/5/25.
//

import Foundation
import Domain
import ComposableArchitecture
import SettlementDetailFeature

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
        @Presents public var settlementDetail: SettlementDetailFeature.State?

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

        // 포맷팅된 총 지출 금액 (억/만 단위)
        public var formattedTotalExpenseAmount: String {
            CurrencyFormatter.formatKoreanCurrency(settlementCalculation.totalExpenseAmount)
        }

        // 포맷팅된 내 부담 금액 (억/만 단위)
        public var formattedMyExpenseAmount: String {
            CurrencyFormatter.formatKoreanCurrency(settlementCalculation.myShareAmount)
        }

        // 포맷팅된 1인 평균 금액 (억/만 단위)
        public var formattedAveragePerPerson: String {
            CurrencyFormatter.formatKoreanCurrency(settlementCalculation.averagePerPerson)
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
            case detailButtonTapped
        }

        @CasePathable
        public enum ScopeAction {
            case alert(PresentationAction<AlertAction>)
            case settlementDetail(PresentationAction<SettlementDetailFeature.Action>)
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
                state.settlementCalculation = calculateSettlementUseCase.execute(
                    expenses: state.expenses,
                    currentUserId: state.currentUserId
                )
                return .none

            case .view(.backButtonTapped):
                return .none

            case .view(.detailButtonTapped):
                // 상세보기 sheet 열기
                guard let currentUserId = state.currentUserId else { return .none }
                state.settlementDetail = SettlementDetailFeature.State(
                    memberDetails: state.settlementCalculation.memberDetails,
                    currentUserId: currentUserId
                )
                return .none

            case .scope, .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.scope.alert)
        .ifLet(\.$settlementDetail, action: \.scope.settlementDetail) {
            SettlementDetailFeature()
        }
    }
}
