//
//  ParticipantSelector.swift
//  ExpenseFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem
import Domain
import IdentifiedCollections

public struct ParticipantSelector: View {
    @Binding var payer: Expense.Participant?
    @Binding var participants: IdentifiedArrayOf<Expense.Participant>
    let availableParticipants: IdentifiedArrayOf<Expense.Participant>
    
    public init(
        payer: Binding<Expense.Participant?>,
        participants: Binding<IdentifiedArrayOf<Expense.Participant>>,
        availableParticipants: IdentifiedArrayOf<Expense.Participant>
    ) {
        self._payer = payer
        self._participants = participants
        self.availableParticipants = availableParticipants
    }
    
    @State private var showPayerDialog = false
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 결제자 선택 (Dialog)
            VStack(alignment: .leading, spacing: 8) {
                FormLabel("결제자")
                
                Button {
                    showPayerDialog = true
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
                .confirmationDialog(
                    "결제자 선택",
                    isPresented: $showPayerDialog,
                    titleVisibility: .visible
                ) {
                    ForEach(availableParticipants, id: \.memberId) { participant in
                        Button(participant.name) {
                            payer = participant
                            // 결제자는 자동으로 참여자에 포함되어야 함
                            if !participants.contains(where: { $0.memberId == participant.memberId }) {
                                participants.append(participant)
                            }
                        }
                    }
                    Button("취소", role: .cancel) {}
                }
            }
            
            // 참여자 선택 (List Box)
            VStack(alignment: .leading, spacing: 8) {
                FormLabel("참여자")
                
                VStack(spacing: 12) {
                    ForEach(availableParticipants, id: \.memberId) { participant in
                        VStack(spacing: 12) {
                            Button {
                                toggleParticipant(participant)
                            } label: {
                                HStack(spacing: 12) {
                                    // Avatar
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .foregroundStyle(Color.primary500)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                    
                                    Text(participant.name)
                                        .foregroundStyle(Color.primary800)
                                        .font(.system(size: 16))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(
                                            participants.contains(where: { $0.memberId == participant.memberId })
                                            ? Color.primary500
                                            : Color.gray
                                        )
                                        .font(.system(size: 16))
                                }
                                .contentShape(Rectangle())
                            }
                            .disabled(payer?.memberId == participant.memberId) // 결제자는 선택 해제 불가 (비활성화)
                            
                            if participant.memberId != availableParticipants.last?.memberId {
                                Divider()
                            }
                        }
                    }
                }
                .padding(16)
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
        // 결제자는 해제 불가
        guard payer?.memberId != participant.memberId else { return }
        
        if let index = participants.firstIndex(where: { $0.memberId == participant.memberId }) {
            participants.remove(at: index)
        } else {
            participants.append(participant)
        }
    }
}

#Preview {
    @Previewable @State var payer: Expense.Participant? = nil
    @Previewable @State var participants: IdentifiedArrayOf<Expense.Participant> = []
    
    let sampleParticipants = IdentifiedArray(uniqueElements: [
        Expense.Participant(memberId: "1", name: "김민수"),
        Expense.Participant(memberId: "2", name: "이영희"),
        Expense.Participant(memberId: "3", name: "박철수")
    ])
    
    ParticipantSelector(
        payer: $payer,
        participants: $participants,
        availableParticipants: sampleParticipants
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
