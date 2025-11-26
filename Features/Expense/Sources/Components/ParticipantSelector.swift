//
//  ParticipantSelector.swift
//  ExpenseFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem
import Domain

public struct ParticipantSelector: View {
    @Binding var payer: Expense.Participant?
    @Binding var participants: [Expense.Participant]
    let availableParticipants: [Expense.Participant]
    
    public init(
        payer: Binding<Expense.Participant?>,
        participants: Binding<[Expense.Participant]>,
        availableParticipants: [Expense.Participant]
    ) {
        self._payer = payer
        self._participants = participants
        self.availableParticipants = availableParticipants
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 결제자 선택 (Dropdown)
            VStack(alignment: .leading, spacing: 8) {
                FormLabel("결제자")
                
                Menu {
                    ForEach(availableParticipants, id: \.memberId) { participant in
                        Button {
                            payer = participant
                        } label: {
                            HStack {
                                Text(participant.name)
                                if payer?.memberId == participant.memberId {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    InputContainer {
                        HStack {
                            Text(payer?.name ?? "결제자 선택")
                                .foregroundStyle(payer == nil ? Color.gray : Color.primary800)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.gray)
                                .font(.system(size: 14))
                        }
                    }
                }
            }
            
            // 참여자 선택 (List Box)
            VStack(alignment: .leading, spacing: 8) {
                FormLabel("참여자")
                
                VStack(spacing: 0) {
                    ForEach(availableParticipants, id: \.memberId) { participant in
                        Button {
                            toggleParticipant(participant)
                        } label: {
                            HStack(spacing: 12) {
                                // Avatar
                                Circle()
                                    .fill(Color.blue) // TODO: Use DesignSystem Color
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 16))
                                    )
                                
                                Text(participant.name)
                                    .foregroundStyle(Color.primary800)
                                    .font(.system(size: 16))
                                
                                Spacer()
                                
                                if participants.contains(where: { $0.memberId == participant.memberId }) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.gray)
                                        .font(.system(size: 16))
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 56)
                            .contentShape(Rectangle())
                        }
                        
                        if participant.memberId != availableParticipants.last?.memberId {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    private func toggleParticipant(_ participant: Expense.Participant) {
        if let index = participants.firstIndex(where: { $0.memberId == participant.memberId }) {
            participants.remove(at: index)
        } else {
            participants.append(participant)
        }
    }
}

#Preview {
    @Previewable @State var payer: Expense.Participant? = nil
    @Previewable @State var participants: [Expense.Participant] = []
    
    let sampleParticipants = [
        Expense.Participant(memberId: "1", name: "김민수"),
        Expense.Participant(memberId: "2", name: "이영희"),
        Expense.Participant(memberId: "3", name: "박철수")
    ]
    
    ParticipantSelector(
        payer: $payer,
        participants: $participants,
        availableParticipants: sampleParticipants
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
