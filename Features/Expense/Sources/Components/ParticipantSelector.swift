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
    let label: String
    @Binding var selectedParticipants: [Expense.Participant]
    let availableParticipants: [Expense.Participant]
    let multipleSelection: Bool
    
    public init(
        label: String,
        selectedParticipants: Binding<[Expense.Participant]>,
        availableParticipants: [Expense.Participant],
        multipleSelection: Bool = true
    ) {
        self.label = label
        self._selectedParticipants = selectedParticipants
        self.availableParticipants = availableParticipants
        self.multipleSelection = multipleSelection
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.primary800)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(availableParticipants, id: \.memberId) { participant in
                        ParticipantChip(
                            participant: participant,
                            isSelected: selectedParticipants.contains(where: { $0.memberId == participant.memberId })
                        ) {
                            toggleParticipant(participant)
                        }
                    }
                }
            }
        }
    }
    
    private func toggleParticipant(_ participant: Expense.Participant) {
        if let index = selectedParticipants.firstIndex(where: { $0.memberId == participant.memberId }) {
            selectedParticipants.remove(at: index)
        } else {
            if multipleSelection {
                selectedParticipants.append(participant)
            } else {
                selectedParticipants = [participant]
            }
        }
    }
}

private struct ParticipantChip: View {
    let participant: Expense.Participant
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(participant.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? Color.white : Color.primary800)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.primary500 : Color.gray2.opacity(0.3))
                .cornerRadius(20)
        }
    }
}

#Preview {
    @Previewable @State var selectedParticipants: [Expense.Participant] = []
    
    let participants = [
        Expense.Participant(memberId: "1", name: "홍석현"),
        Expense.Participant(memberId: "2", name: "김철수"),
        Expense.Participant(memberId: "3", name: "이영희")
    ]
    
    VStack(spacing: 20) {
        ParticipantSelector(
            label: "지불자",
            selectedParticipants: $selectedParticipants,
            availableParticipants: participants,
            multipleSelection: false
        )
        
        ParticipantSelector(
            label: "참가자",
            selectedParticipants: $selectedParticipants,
            availableParticipants: participants,
            multipleSelection: true
        )
    }
    .padding()
}
