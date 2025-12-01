//
//  ExpenseFeature.swift
//  ExpenseFeature
//
//  Created by 홍석현 on 11/27/25.
//

import Foundation
import ComposableArchitecture
import Domain
import IdentifiedCollections

@Reducer
public struct ExpenseFeature {
    @Dependency(\.fetchTravelDetailUseCase) var fetchTravelDetailUseCase
    @Dependency(\.createExpenseUseCase) var createExpenseUseCase
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    public struct State: Equatable, Hashable {
        var amount: String = ""
        var title: String = ""
        var expenseDate: Date = Date()
        var selectedCategory: ExpenseCategory? = nil
        let travelId: String

        // Travel info
        var baseCurrency: String = ""
        var baseExchangeRate: Double = 1.0
        var convertedAmountKRW: String = ""
        var travelStartDate: Date?
        var travelEndDate: Date?

        // ParticipantSelector Feature
        var participantSelector: ParticipantSelectorFeature.State

        public init(_ travelId: String) {
            self.travelId = travelId
            self.participantSelector = ParticipantSelectorFeature.State(availableParticipants: [])
        }

        // 저장 버튼 활성화 조건
        var canSave: Bool {
            // 1. 제목이 비어있지 않아야 함
            guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return false }

            // 2. 금액이 0보다 커야 함
            guard let amountValue = Double(amount), amountValue > 0 else { return false }

            // 3. 카테고리가 선택되어야 함
            guard selectedCategory != nil else { return false }

            // 4. 결제자가 선택되어야 함
            guard participantSelector.payer != nil else { return false }

            // 5. 참여자가 1명 이상이어야 함
            guard !participantSelector.participants.isEmpty else { return false }

            return true
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
            case onAppear
            case saveButtonTapped
        }
        
        @CasePathable
        public enum InnerAction {
            case loadTravelDetailResponse(Result<Travel, Error>)
            case saveExpenseResponse(Result<Void, Error>)
        }
        
        @CasePathable
        public enum AsyncAction {
            case loadTravelDetail
            case saveExpense
        }
        
        @CasePathable
        public enum ScopeAction {
            case participantSelector(ParticipantSelectorFeature.Action)
        }
        
        @CasePathable
        public enum DelegateAction {
            case finishSaveExpense
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
            case .scope:
                return .none
            case .delegate:
                return .none
            }
        }
    }
}

extension ExpenseFeature {
    // MARK: - View Action Handler
    private func handleViewAction(state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .send(.async(.loadTravelDetail))
        case .saveButtonTapped:
            return .send(.async(.saveExpense))
        }
    }
    
    // MARK: - Inner Action Handler
    private func handleInnerAction(state: inout State, action: Action.InnerAction) -> Effect<Action> {
        switch action {
        case .loadTravelDetailResponse(.success(let travel)):
            // Populate travel info
            state.baseCurrency = travel.baseCurrency
            state.baseExchangeRate = travel.baseExchangeRate
            state.travelStartDate = travel.startDate
            state.travelEndDate = travel.endDate
            state.participantSelector.availableParticipants = IdentifiedArray(uniqueElements: travel.members)
            // Recalculate amount conversion if amount already entered
            recalculateConvertedAmount(&state)
            return .none
            
        case .loadTravelDetailResponse(.failure(let error)):
            print("Travel detail 로드 실패: \(error)")
            return .none
            
        case .saveExpenseResponse(.success):
            return .send(.delegate(.finishSaveExpense))
            
        case .saveExpenseResponse(.failure(let error)):
            // TODO: 에러 처리 (알림 표시 등)
            print("저장 실패: \(error)")
            return .none
        }
    }
    
    // MARK: - Async Action Handler
        private func handleAsyncAction(state: inout State, action: Action.AsyncAction) -> Effect<Action> {
            switch action {
            case .loadTravelDetail:
                return .run { [travelId = state.travelId] send in
                    do {
                        let travel = try await fetchTravelDetailUseCase.execute(id: travelId)
                        await send(.inner(.loadTravelDetailResponse(.success(travel))))
                    } catch {
                        await send(.inner(.loadTravelDetailResponse(.failure(error))))
                    }
                }
            case .saveExpense:
                guard let category = state.selectedCategory,
                      let payer = state.participantSelector.payer,
                      let amountValue = Double(state.amount) else {
                    return .none
                }

                let input = CreateExpenseInput(
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

                return .run { [travelId = state.travelId] send in
                    do {
                        try await createExpenseUseCase.execute(travelId: travelId, input: input)
                        await send(.inner(.saveExpenseResponse(.success(()))))
                    } catch {
                        await send(.inner(.saveExpenseResponse(.failure(error))))
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
