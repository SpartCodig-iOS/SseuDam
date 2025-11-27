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
    @ObservableState
    public struct State: Equatable {
        var amount: String = ""
        var title: String = ""
        var expenseDate: Date = Date()
        var selectedCategory: ExpenseCategory? = nil
        
        // ParticipantSelector Feature
        var participantSelector: ParticipantSelectorFeature.State
        
        public init() {
            let availableParticipants = IdentifiedArray(uniqueElements: [
                TravelMember(id: "1", name: "홍석현", role: "owner"),
                TravelMember(id: "2", name: "김철수", role: "member"),
                TravelMember(id: "3", name: "이영희", role: "member"),
                TravelMember(id: "4", name: "박민수", role: "member")
            ])
            self.participantSelector = ParticipantSelectorFeature.State(
                availableParticipants: availableParticipants
            )
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
            case saveButtonTapped
        }
        
        @CasePathable
        public enum InnerAction {
            
        }
        
        @CasePathable
        public enum AsyncAction {
            case saveExpense
            case saveExpenseResponse(Result<Void, Error>)
        }
        
        @CasePathable
        public enum ScopeAction {
            case participantSelector(ParticipantSelectorFeature.Action)
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
                return .none
                
            case .binding(\.selectedCategory):
                // 카테고리 변경 시 추가 로직
                if let category = state.selectedCategory {
                    print("카테고리 선택됨: \(category.displayName)")
                }
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
            }
        }
    }
}

extension ExpenseFeature {
    // MARK: - View Action Handler
    private func handleViewAction(state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .saveButtonTapped:
            return .send(.async(.saveExpense))
        }
    }
    
    // MARK: - Inner Action Handler
    private func handleInnerAction(state: inout State, action: Action.InnerAction) -> Effect<Action> {
        switch action {
        }
    }
    
    // MARK: - Async Action Handler
    private func handleAsyncAction(state: inout State, action: Action.AsyncAction) -> Effect<Action> {
        switch action {
        case .saveExpense:
            // TODO: Repository 연동하여 실제 저장 로직 구현
            return .run { send in
                do {
                    // 임시 저장 로직
                    try await Task.sleep(for: .seconds(1))
                    await send(.async(.saveExpenseResponse(.success(()))))
                } catch {
                    await send(.async(.saveExpenseResponse(.failure(error))))
                }
            }
            
        case .saveExpenseResponse(.success):
            // TODO: 성공 처리 (화면 닫기, 토스트 표시 등)
            return .none
            
        case .saveExpenseResponse(.failure(let error)):
            // TODO: 에러 처리 (알림 표시 등)
            print("저장 실패: \(error)")
            return .none
        }
    }
}
