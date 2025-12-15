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
        @Shared public var travel: Travel?
        @Shared public var allExpenses: [Expense]
        public var currentExpense: [Expense] = []
        public var startDate: Date {
            return travel?.startDate ?? Date()
        }
        public var endDate: Date {
            return travel?.endDate ?? Date()
        }
        public var selectedDateRange: ClosedRange<Date>? = nil
        public var currentPage: Int = 0
        public var selectedCategory: ExpenseCategory? = nil
        public let travelId: String
        public var isLoading: Bool = false
        @Presents public var alert: AlertState<Action.AlertAction>?
        public var pendingHighlightExpenseId: String?
        /// 포맷팅된 총 지출 금액 문자열
        public var formattedTotalAmount: String {
            let total = currentExpense.reduce(0.0) { $0 + $1.convertedAmount }
            return total.formatted(.number.precision(.fractionLength(0)))
        }

        public init(
            travelId: String,
            travel: Shared<Travel?>,
            expenses: Shared<[Expense]>
        ) {
            self.travelId = travelId
            self._travel = travel
            self._allExpenses = expenses
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
        case highlightExpense(String)

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
            case .scope:
                return .none
            case .delegate:
                return .none
            case .binding(\.selectedDateRange):
                // 날짜 범위 변경 시 필터링
                applyFilters(&state)
                
                // 선택된 날짜에 맞는 페이지로 이동
                if let range = state.selectedDateRange {
                    let calendar = Calendar.current
                    let startDay = calendar.startOfDay(for: state.startDate)
                    let rangeStartDay = calendar.startOfDay(for: range.lowerBound)
                    
                    if let days = calendar.dateComponents([.day], from: startDay, to: rangeStartDay).day {
                        state.currentPage = days / 7
                    }
                }
                return .none
            case .binding(\.currentPage):
                // 페이지 변경 시 선택된 날짜 초기화 및 해당 페이지 데이터로 필터링
                state.selectedDateRange = nil
                applyFilters(&state)
                return .none
            case .binding(\.selectedCategory):
                // 카테고리 변경 시 필터링
                applyFilters(&state)
                return .none
            case .binding:
                return .none

            case .highlightExpense(let expenseId):
                state.pendingHighlightExpenseId = expenseId
                applyExpenseHighlight(&state)
                return .none
            }
        }
        .ifLet(\.$alert, action: \.scope.alert)
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
            state.$allExpenses.withLock {
                $0 = expenses
            }
            applyExpenseHighlight(&state)
            // 현재 선택된 필터 적용
            applyFilters(&state)
            state.isLoading = false
            return .none

        case let .expensesResponse(.failure(error)):
            state.isLoading = false
            state.alert = AlertState {
                TextState("오류")
            } actions: {
                ButtonState(action: .confirmTapped) {
                    TextState("확인")
                }
            } message: {
                TextState("지출 정보를 불러오는데 실패했습니다.\n\(error.localizedDescription)")
            }
            return .none
        }
    }

    // MARK: - Async Action Handler
    private func handleAsyncAction(state: inout State, action: Action.AsyncAction) -> Effect<Action> {
        switch action {
        case .fetchData:
            let travelId = state.travelId
            // allExpenses가 비어있을 때만 로딩 표시
            if state.allExpenses.isEmpty {
                state.isLoading = true
            }
            return .run { send in
                // AsyncStream을 순회하며 결과 처리
                for await result in fetchTravelExpenseUseCase.execute(travelId: travelId, date: nil) {
                    await send(.inner(.expensesResponse(result)))
                }
            }
        }
    }

    // MARK: - Helper Methods
    private func applyFilters(_ state: inout State) {
        let calendar = Calendar.current

        state.currentExpense = state.allExpenses.filter { expense in
            // 날짜 범위 필터링
            if let range = state.selectedDateRange {
                let rangeStart = calendar.startOfDay(for: range.lowerBound)
                let rangeEnd = calendar.startOfDay(for: range.upperBound)
                let expenseDay = calendar.startOfDay(for: expense.expenseDate)

                guard expenseDay >= rangeStart && expenseDay <= rangeEnd else {
                    return false
                }
            } else {
                // 선택된 날짜가 없으면 현재 페이지(7일)에 해당하는지 확인
                // 페이지 시작일 = 여행 시작일 + (currentPage * 7)일
                if let pageStart = calendar.date(byAdding: .day, value: state.currentPage * 7, to: state.startDate) {
                    let pageStartDay = calendar.startOfDay(for: pageStart)
                    // 페이지 끝일 = 시작일 + 6일
                    let pageEndDay = calendar.date(byAdding: .day, value: 6, to: pageStartDay) ?? Date()
                    
                    let expenseDay = calendar.startOfDay(for: expense.expenseDate)
                    
                    guard expenseDay >= pageStartDay && expenseDay <= pageEndDay else {
                        return false
                    }
                }
            }

            // 카테고리 필터링
            if let category = state.selectedCategory {
                guard expense.category == category else {
                    return false
                }
            }

            return true
        }
    }

    private func applyExpenseHighlight(_ state: inout State) {
        guard let targetId = state.pendingHighlightExpenseId else { return }
        guard let expense = state.allExpenses.first(where: { $0.id == targetId }) else { return }
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: expense.expenseDate)
        // 단일 날짜 선택 (같은 날짜의 범위)
        state.selectedDateRange = targetDate...targetDate
        applyFilters(&state)
        state.pendingHighlightExpenseId = nil
    }
}
