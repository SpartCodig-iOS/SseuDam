//
//  ParticipantSelectorFeature.swift
//  ExpenseFeature
//
//  Created by SseuDam on 2025.
//

import Foundation
import ComposableArchitecture
import Domain
import IdentifiedCollections

@Reducer
public struct ParticipantSelectorFeature {
    @ObservableState
    public struct State: Equatable, Hashable {
        var payer: TravelMember?
        var participants: IdentifiedArrayOf<TravelMember> = []
        var availableParticipants: IdentifiedArrayOf<TravelMember>
        
        @Presents var payerDialog: ConfirmationDialogState<Action.PayerDialog>?
        
        public init(
            availableParticipants: IdentifiedArrayOf<TravelMember>,
            payer: TravelMember? = nil,
            participants: IdentifiedArrayOf<TravelMember> = []
        ) {
            self.availableParticipants = availableParticipants
        }
    }
    
    @CasePathable
    public enum Action: Equatable, ViewAction {
        case view(ViewAction)
        case inner(InnerAction)
        case scope(ScopeAction)
        
        @CasePathable
        public enum ViewAction: Equatable {
            case payerButtonTapped
            case participantToggled(TravelMember)
        }

        @CasePathable
        public enum InnerAction: Equatable {
            case updatePayer(TravelMember)
            case updateParticipants(IdentifiedArrayOf<TravelMember>)
        }

        @CasePathable
        public enum ScopeAction: Equatable {
            case payerDialog(PresentationAction<PayerDialog>)
        }

        @CasePathable
        public enum PayerDialog: Equatable, Hashable {
            case selectPayer(TravelMember)
        }
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(let viewAction):
                return handleViewAction(state: &state, action: viewAction)
            case .inner(let innerAction):
                return handleInnerAction(state: &state, action: innerAction)
            case .scope(.payerDialog(.presented(.selectPayer(let participant)))):
                return .send(.inner(.updatePayer(participant)))
            case .scope:
                return .none
            }
        }
        .ifLet(\.$payerDialog, action: \.scope.payerDialog)
    }
}

extension ParticipantSelectorFeature {
    // MARK: - View Action Handler
    private func handleViewAction(state: inout State, action: Action.ViewAction) -> Effect<Action> {
        switch action {
        case .payerButtonTapped:
            state.payerDialog = ConfirmationDialogState(
                title: { TextState("결제자 선택") },
                actions: {
                    return state.availableParticipants.map { participant in
                        ButtonState(action: .selectPayer(participant)) {
                            TextState(participant.name)
                        }
                    } + [
                        ButtonState(role: .cancel) {
                            TextState("취소")
                        }
                    ]
                }
            )
            return .none
            
        case .participantToggled(let participant):
            var updatedParticipants = state.participants
            if updatedParticipants.contains(participant) {
                updatedParticipants.remove(id: participant.id)
            } else {
                updatedParticipants.append(participant)
            }
            return .send(.inner(.updateParticipants(updatedParticipants)))
        }
    }
    
    // MARK: - Inner Action Handler
    private func handleInnerAction(state: inout State, action: Action.InnerAction) -> Effect<Action> {
        switch action {
        case .updatePayer(let participant):
            state.payer = participant
            // 결제자는 자동으로 참여자에 포함
            if !state.participants.contains(participant) {
                state.participants.append(participant)
            }
            return .none
            
        case .updateParticipants(let participants):
            state.participants = participants
            return .none
        }
    }
}
