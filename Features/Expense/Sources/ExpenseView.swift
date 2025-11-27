//
//  ExpenseView.swift
//  SseuDam
//
//  Created by SseuDam on 2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import DesignSystem
import Domain
import IdentifiedCollections

public struct ExpenseView: View {
    @State private var amount: String = ""
    @State private var selectedCategory: ExpenseCategory? = nil
    @State private var title: String = ""
    @State private var expenseDate: Date = Date()
    @State private var payer: Expense.Participant? = nil
    @State private var participants: IdentifiedArrayOf<Expense.Participant> = []
    
    // 샘플 참가자 데이터
    private let availableParticipants = IdentifiedArray(uniqueElements: [
        Expense.Participant(memberId: "1", name: "홍석현"),
        Expense.Participant(memberId: "2", name: "김철수"),
        Expense.Participant(memberId: "3", name: "이영희"),
        Expense.Participant(memberId: "4", name: "박민수")
    ])
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 10) {
            ScrollView {
                VStack(spacing: 24) {
                    // 1. 지출 금액
                    AmountInputField(amount: $amount)
                    
                    // 2. 지출 제목
                    TextInputField(
                        label: "지출 제목",
                        placeholder: "ex) 점심 식사",
                        text: $title
                    )
                    
                    // 3. 지출일
                    DatePickerField(label: "지출일", date: $expenseDate)
                    
                    // 4. 카테고리
                    CategorySelector(selectedCategory: $selectedCategory)
                    
                    // 5. 결제자 & 참여자
                    ParticipantSelector(
                        payer: $payer,
                        participants: $participants,
                        availableParticipants: availableParticipants
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            
            PrimaryButton(title: "저장") {
                saveExpense()
            }
            .padding(.horizontal, 16)
            .background(Color.clear)
        }
        .navigationTitle("지출 추가") // 타이틀 변경
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
    }
    
    private func saveExpense() {
        // TODO: TCA Action 연동
        print("Save expense")
    }
}

#Preview {
    NavigationStack {
        ExpenseView()
    }
}
