//
//  SaveExpenseFeature.swift
//  SaveExpenseFeature
//
//  Created by 홍석현 on 11/27/25.
//

import Foundation
import ComposableArchitecture
import Domain
import IdentifiedCollections

public enum ExpenseEditType {
    case create
    case edit
    case delete
    
    public var displayName: String {
        switch self {
        case .create: "생성"
        case .edit: "수정"
        case .delete: "삭제"
        }
    }
}

@Reducer
public struct SaveExpenseFeature {
    @Dependency(\.createExpenseUseCase) var createExpenseUseCase
    @Dependency(\.updateExpenseUseCase) var updateExpenseUseCase
    @Dependency(\.deleteExpenseUseCase) var deleteExpenseUseCase

    @ObservableState
    public struct State: Equatable, Hashable {
        let travel: Travel
        let expense: Expense?

        var amount: String = ""
        var title: String = ""
        var expenseDate: Date
        var selectedCategory: ExpenseCategory? = nil
        var convertedAmountKRW: String = ""
        var isLoading: Bool = false

        @Presents var deleteAlert: AlertState<Action.Alert>?

        // ParticipantSelector Feature
        var participantSelector: ParticipantSelectorFeature.State

        // Computed properties
        var travelId: String { travel.id }
        var expenseId: String? { expense?.id }
        var isEditMode: Bool { expense != nil }
        var baseCurrency: String { travel.baseCurrency }
        var baseExchangeRate: Double { travel.baseExchangeRate }
        var travelStartDate: Date { travel.startDate }
        var travelEndDate: Date { travel.endDate }

        // 새 지출 추가
        public init(travel: Travel) {
            self.travel = travel
            self.expense = nil
            self.expenseDate = travel.startDate
            self.participantSelector = ParticipantSelectorFeature.State(
                availableParticipants: IdentifiedArray(uniqueElements: travel.members)
            )
        }

        // 지출 수정
        public init(travel: Travel, expense: Expense) {
            self.travel = travel
            self.expense = expense

            // 기존 지출 데이터로 초기화
            self.title = expense.title
            self.amount = String(expense.amount)
            self.expenseDate = expense.expenseDate
            self.selectedCategory = expense.category

            // ParticipantSelector 초기화
            self.participantSelector = ParticipantSelectorFeature.State(
                availableParticipants: IdentifiedArray(uniqueElements: travel.members),
                payer: travel.members.first { $0.id == expense.payerId },
                participants: IdentifiedArray(uniqueElements: expense.participants)
            )

            // 환산 금액 계산
            if travel.baseCurrency != "KRW" {
                let convertedKRW = expense.amount * travel.baseExchangeRate
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 0
                self.convertedAmountKRW = formatter.string(from: NSNumber(value: convertedKRW)) ?? ""
            }
        }

        // 저장 버튼 활성화 조건
        var canSave: Bool {
            // 기본 유효성 검사
            guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
            guard let amountValue = Double(amount), amountValue > 0 else { return false }
            guard selectedCategory != nil else { return false }
            guard participantSelector.payer != nil else { return false }
            guard !participantSelector.participants.isEmpty else { return false }

            // 수정 모드일 경우: 원본과 비교하여 변경이 있어야 함
            if let originalExpense = expense {
                return hasChanges(from: originalExpense)
            }

            // 새로운 지출 추가 모드: 기본 유효성만 통과하면 됨
            return true
        }

        // 원본 expense와 현재 입력값 비교
        private func hasChanges(from original: Expense) -> Bool {
            // 제목 변경 확인
            if title != original.title {
                return true
            }

            // 금액 변경 확인
            if let amountValue = Double(amount), amountValue != original.amount {
                return true
            }

            // 날짜 변경 확인
            let calendar = Calendar.current
            if !calendar.isDate(expenseDate, inSameDayAs: original.expenseDate) {
                return true
            }

            // 카테고리 변경 확인
            if selectedCategory != original.category {
                return true
            }

            // 결제자 변경 확인
            if participantSelector.payer?.id != original.payerId {
                return true
            }

            // 참여자 변경 확인 (ID 기준)
            let currentParticipantIds = Set(participantSelector.participants.map { $0.id })
            let originalParticipantIds = Set(original.participants.map { $0.id })
            if currentParticipantIds != originalParticipantIds {
                return true
            }

            return false
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

        @CasePathable
        public enum ViewAction {
            case saveButtonTapped
            case deleteButtonTapped
            case backButtonTapped
        }

        @CasePathable
        public enum Alert {
            case confirmDelete
        }

        @CasePathable
        public enum InnerAction {
            case saveExpenseResponse(Result<Void, Error>)
            case deleteExpenseResponse(Result<Void, Error>)
        }

        @CasePathable
        public enum AsyncAction {
            case saveExpense
            case deleteExpense
        }
        
        @CasePathable
        public enum ScopeAction {
            case participantSelector(ParticipantSelectorFeature.Action)
            case deleteAlert(PresentationAction<Alert>)
        }
        
        @CasePathable
        public enum DelegateAction {
            case finishSaveExpense(type: ExpenseEditType)
            case onTapBackButton
        }
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        Scope(state: \.participantSelector, action: \.scope.participantSelector) {
            ParticipantSelectorFeature()
        }

        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.amount):
                // amount 변경 시 추가 로직 (예: 유효성 검사, 로그 등)
                print("금액 변경됨: \(state.amount)")
                recalculateConvertedAmount(&state)
                return .none
            case .binding:
                // 다른 바인딩 변경은 BindingReducer가 자동 처리
                return .none

            case .view(let viewAction):
                return handleViewAction(state: &state, action: viewAction)
            case .inner(let innerAction):
                return handleInnerAction(state: &state, action: innerAction)
            case .async(let asyncAction):
                return handleAsyncAction(state: &state, action: asyncAction)
            case .scope(.deleteAlert(.presented(.confirmDelete))):
                return .send(.async(.deleteExpense))
            case .scope:
                return .none
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$deleteAlert, action: \.scope.deleteAlert)
    }
}

extension SaveExpenseFeature {
    // MARK: - View Action Handler
    private func handleViewAction(state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .saveButtonTapped:
            return .send(.async(.saveExpense))

        case .deleteButtonTapped:
            state.deleteAlert = AlertState {
                TextState("이 지출 내역을 삭제하시겠어요?")
            } actions: {
                ButtonState(role: .destructive, action: .confirmDelete) {
                    TextState("삭제하기")
                }
                ButtonState(role: .cancel) {
                    TextState("취소")
                }
            } message: {
                TextState("삭제된 지출 내역은 다시 복구할 수 없습니다.")
            }
            return .none

        case .backButtonTapped:
            // Coordinator가 pop을 처리하도록 delegate로 전달
            return .send(.delegate(.onTapBackButton))
        }
    }

    // MARK: - Inner Action Handler
    private func handleInnerAction(state: inout State, action: Action.InnerAction) -> Effect<Action> {
        switch action {
        case .saveExpenseResponse(.success):
            state.isLoading = false
            return .send(
                .delegate(
                    .finishSaveExpense(
                        type: state.expense == nil ? .create : .edit
                    )
                )
            )

        case .saveExpenseResponse(.failure(let error)):
            state.isLoading = false
            // TODO: 에러 처리 (알림 표시 등)
            print("저장 실패: \(error)")
            return .none

        case .deleteExpenseResponse(.success):
            state.isLoading = false
            return .send(
                .delegate(
                    .finishSaveExpense(
                        type: .delete
                    )
                )
            )

        case .deleteExpenseResponse(.failure(let error)):
            state.isLoading = false
            // TODO: 에러 처리 (알림 표시 등)
            print("삭제 실패: \(error)")
            return .none
        }
    }
    
    // MARK: - Async Action Handler
    private func handleAsyncAction(state: inout State, action: Action.AsyncAction) -> Effect<Action> {
        switch action {
        case .saveExpense:
            guard let category = state.selectedCategory,
                  let payer = state.participantSelector.payer,
                  let amountValue = Double(state.amount) else {
                return .none
            }

            let expense = Expense(
                id: state.expenseId ?? UUID().uuidString,
                title: state.title,
                amount: amountValue,
                currency: state.baseCurrency,
                convertedAmount: state.baseCurrency == "KRW" ? amountValue : amountValue * state.baseExchangeRate,
                expenseDate: state.expenseDate,
                category: category,
                payerId: payer.id,
                payerName: payer.name,
                participants: Array(state.participantSelector.participants)
            )

            let isEditMode = state.isEditMode
            state.isLoading = true
            return .run { [travelId = state.travelId] send in
                do {
                    if isEditMode {
                        try await updateExpenseUseCase.execute(travelId: travelId, expense: expense)
                    } else {
                        let input = CreateExpenseInput(
                            title: expense.title,
                            amount: expense.amount,
                            currency: expense.currency,
                            convertedAmount: expense.convertedAmount,
                            expenseDate: expense.expenseDate,
                            category: expense.category,
                            payerId: expense.payerId,
                            payerName: expense.payerName,
                            participants: expense.participants
                        )
                        try await createExpenseUseCase.execute(travelId: travelId, input: input)
                    }
                    await send(.inner(.saveExpenseResponse(.success(()))))
                } catch {
                    await send(.inner(.saveExpenseResponse(.failure(error))))
                }
            }

        case .deleteExpense:
            guard let expenseId = state.expenseId else {
                return .none
            }

            state.isLoading = true
            return .run { [travelId = state.travelId] send in
                do {
                    try await deleteExpenseUseCase.execute(travelId: travelId, expenseId: expenseId)
                    await send(.inner(.deleteExpenseResponse(.success(()))))
                } catch {
                    await send(.inner(.deleteExpenseResponse(.failure(error))))
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func recalculateConvertedAmount(_ state: inout State) {
        // KRW 기준이면 환산 불필요
        guard state.baseCurrency != "KRW" else {
            state.convertedAmountKRW = ""
            return
        }

        guard let amount = Double(state.amount), amount > 0 else {
            state.convertedAmountKRW = ""
            return
        }

        // 외국 통화 → KRW 환산
        let convertedKRW = amount * state.baseExchangeRate

        // NumberFormatter로 천단위 콤마 추가
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        state.convertedAmountKRW = formatter.string(from: NSNumber(value: convertedKRW)) ?? ""
    }
}
