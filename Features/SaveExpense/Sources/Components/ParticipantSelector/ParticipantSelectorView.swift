//
//  ParticipantSelectorView.swift
//  SaveExpenseFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem
import Domain
import ComposableArchitecture

@ViewAction(for: ParticipantSelectorFeature.self)
public struct ParticipantSelectorView: View {
    public let store: StoreOf<ParticipantSelectorFeature>
    
    public init(store: StoreOf<ParticipantSelectorFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 결제자 선택 (Dialog)
            VStack(alignment: .leading, spacing: 8) {
                FormLabel("결제자")
                
                Button {
                    send(.payerButtonTapped)
                } label: {
                    InputContainer {
                        HStack {
                            Text(store.payer?.name ?? "결제자 선택")
                                .font(.app(.body, weight: .medium))
                                .foregroundStyle(store.payer == nil ? Color.gray : Color.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.gray)
                                .font(.system(size: 14))
                        }
                    }
                }
                .confirmationDialog(
                    store: store.scope(state: \.$payerDialog, action: \.scope.payerDialog)
                )
            }
            
            // 참여자 선택 (List Box)
            VStack(alignment: .leading, spacing: 8) {
                FormLabel("참여자")
                
                VStack(spacing: 12) {
                    ForEach(store.availableParticipants, id: \.id) { participant in
                        ParticipantRowView(
                            participant: participant,
                            isSelected: store.participants.contains(participant),
                            isPayer: store.payer?.id == participant.id,
                            showDivider: participant.id != store.availableParticipants.last?.id,
                            action: { send(.participantToggled(participant)) }
                        )
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

private struct ParticipantRowView: View {
    let participant: TravelMember
    let isSelected: Bool
    let isPayer: Bool
    let showDivider: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: action) {
                HStack(spacing: 12) {
                    // Avatar
                    Image(asset: .profile)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                    
                    Text(participant.name)
                        .foregroundStyle(Color.black)
                        .font(.app(.body, weight: .medium))
                    
                    Spacer()

                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color.primary300 : Color.gray2, lineWidth: 1)
                        .frame(width: 28, height: 28)
                        .overlay {
                            if isSelected {
                                Image(asset: .check)
                                    .resizable()
                                    .foregroundStyle(Color.primary300)
                                    .frame(width: 20, height: 24)
                            }
                        }
                }
                .contentShape(Rectangle())
            }
            .disabled(isPayer)
            
            if showDivider {
                Divider()
            }
        }
    }
}

#Preview {
    let sampleParticipants = IdentifiedArray(uniqueElements: [
        TravelMember(id: "1", name: "김민수", role: .owner),
        TravelMember(id: "2", name: "이영희", role: .member),
        TravelMember(id: "3", name: "박철수", role: .member)
    ])

    ParticipantSelectorView(
        store: Store(initialState: ParticipantSelectorFeature.State(availableParticipants: sampleParticipants)) {
            ParticipantSelectorFeature()
        }
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
