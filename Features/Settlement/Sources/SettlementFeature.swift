//
//  SettlementFeature.swift
//  SettlementFeature
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
public struct SettlementFeature {
    @Dependency(\.fetchTravelDetailUseCase) var fetchTravelDetailUseCase
    @Dependency(\.fetchTravelExpenseUseCase) var fetchTravelExpenseUseCase

    public init() {}

    @ObservableState
    public struct State: Equatable, Hashable {
        public var allExpenses: [Expense] = [] // 전체 지출 데이터 (캐싱)
        public var currentExpense: [Expense] = [] // 현재 선택된 날짜의 지출
        public var startDate: Date = Date()
        public var endDate: Date = Date()
        public var selectedDate: Date = Date()
        public var travelTitle: String = ""
        public let travelId: String
        public var travel: Travel? = nil // ExpenseFeature 생성 시 전달용

        public var totalAmount: Int {
            Int(currentExpense.reduce(0) { $0 + $1.convertedAmount })
        }

        public var myExpenseAmount: Int {
            // 임시로 전체 금액과 동일하게 처리 (나중에 내 지출 필터링 로직 추가 필요)
            totalAmount
        }

        public init(_ travelId: String) {
            self.travelId = travelId
        }
    }

    @CasePathable
    public enum Action: BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case view(ViewAction)
        case inner(InnerAction)
        case async(AsyncAction)

        @CasePathable
        public enum ViewAction {
            case onAppear
            case addExpenseButtonTapped
            case onTapExpense(Expense)
        }

        @CasePathable
        public enum InnerAction {
            case travelDetailResponse(Result<Travel, Error>)
            case expensesResponse(Result<[Expense], Error>)
        }

        @CasePathable
        public enum AsyncAction {
            case fetchData
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
            case .binding(\.selectedDate):
                // 로컬 캐시에서 필터링
                filterExpensesByDate(&state, date: state.selectedDate)
                return .none
            case .binding:
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
            return .send(.async(.fetchData))

        case .addExpenseButtonTapped:
            // TODO: 지출 추가 화면으로 네비게이션
            print("Add expense button tapped")
            return .none
        case .onTapExpense:
            return .none
        }
    }

    // MARK: - Inner Action Handler
    private func handleInnerAction(state: inout State, action: Action.InnerAction) -> Effect<Action> {
        switch action {
        case let .travelDetailResponse(.success(travel)):
            state.travel = travel
            state.travelTitle = travel.title
            state.startDate = travel.startDate
            state.endDate = travel.endDate

            // 기본 선택 날짜를 여행 시작일로 설정
            state.selectedDate = travel.startDate
            return .none

        case let .travelDetailResponse(.failure(error)):
            print("Failed to fetch travel detail: \(error)")
            return .none

        case let .expensesResponse(.success(expenses)):
            // 전체 지출 데이터를 캐싱
            state.allExpenses = expenses
            // 현재 선택된 날짜로 필터링
            filterExpensesByDate(&state, date: state.selectedDate)
            return .none

        case let .expensesResponse(.failure(error)):
            print("Failed to fetch expenses: \(error)")
            return .none
        }
    }

    // MARK: - Async Action Handler
    private func handleAsyncAction(state: inout State, action: Action.AsyncAction) -> Effect<Action> {
        switch action {
        case .fetchData:
            let travelId = state.travelId
            return .run { send in
                // 여행 상세 정보 조회
                async let travelDetailResult = Result {
                    try await fetchTravelDetailUseCase.execute(id: travelId)
                }

                // 전체 지출 내역 조회 (date: nil로 전체 조회)
                async let expensesResult = Result {
                    try await fetchTravelExpenseUseCase.execute(travelId: travelId, date: nil)
                }

                await send(.inner(.travelDetailResponse(travelDetailResult)))
                await send(.inner(.expensesResponse(expensesResult)))
            }
        }
    }

    // MARK: - Helper Methods
    private func filterExpensesByDate(_ state: inout State, date: Date) {
        let calendar = Calendar.current
        state.currentExpense = state.allExpenses.filter { expense in
            calendar.isDate(expense.expenseDate, inSameDayAs: date)
        }
    }
}
