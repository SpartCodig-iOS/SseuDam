//
//  ExpenseListFeature.swift
//  ExpenseListFeature
//
//  Created by 홍석현 on 12/8/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
public struct ExpenseListFeature {
    @Dependency(\.fetchTravelExpenseUseCase) var fetchTravelExpenseUseCase

    public init() {}

    @ObservableState
    public struct State: Equatable {
        public var allExpenses: [Expense] = [] // 전체 지출 데이터 (캐싱)
        public var currentExpense: [Expense] = [] // 현재 선택된 날짜의 지출
        public var startDate: Date = Date()
        public var endDate: Date = Date()
        public var selectedDate: Date = Date()
        public let travelId: String
        public var travel: Travel? = nil
        public var isLoading: Bool = false

        public var totalAmount: Int {
            Int(currentExpense.reduce(0) { $0 + $1.convertedAmount })
        }

        public var myExpenseAmount: Int {
            // 임시로 전체 금액과 동일하게 처리 (나중에 내 지출 필터링 로직 추가 필요)
            totalAmount
        }

        public init(travelId: String) {
            self.travelId = travelId
        }
    }

    @CasePathable
    public enum Action: BindableAction, ViewAction {
        case binding(BindingAction<State>)
        case view(ViewAction)
        case inner(InnerAction)
        case async(AsyncAction)
        case delegate(DelegateAction)

        @CasePathable
        public enum ViewAction {
            case onAppear
            case addExpenseButtonTapped
            case onTapExpense(Expense)
        }

        @CasePathable
        public enum InnerAction {
            case expensesResponse(Result<[Expense], Error>)
        }

        @CasePathable
        public enum AsyncAction {
            case fetchData
        }

        @CasePathable
        public enum DelegateAction {
            case onTapAddExpense
            case onTapExpense(Expense)
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
            case .delegate:
                return .none
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

extension ExpenseListFeature {
    // MARK: - View Action Handler
    private func handleViewAction(state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .send(.async(.fetchData))

        case .addExpenseButtonTapped:
            return .send(.delegate(.onTapAddExpense))

        case let .onTapExpense(expense):
            return .send(.delegate(.onTapExpense(expense)))
        }
    }

    // MARK: - Inner Action Handler
    private func handleInnerAction(state: inout State, action: Action.InnerAction) -> Effect<Action> {
        switch action {
        case let .expensesResponse(.success(expenses)):
            // 전체 지출 데이터를 캐싱
            state.allExpenses = expenses
            // 현재 선택된 날짜로 필터링
            filterExpensesByDate(&state, date: state.selectedDate)
            state.isLoading = false
            return .none

        case let .expensesResponse(.failure(error)):
            print("Failed to fetch expenses: \(error)")
            state.isLoading = false
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
                // 전체 지출 내역 조회 (date: nil로 전체 조회)
                let expensesResult = await Result {
                    try await fetchTravelExpenseUseCase.execute(travelId: travelId, date: nil)
                }

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
