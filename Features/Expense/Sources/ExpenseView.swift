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

public struct ExpenseView: View {
    @State private var amount: String = ""
    @State private var selectedCategory: ExpenseCategory? = nil
    @State private var title: String = ""
    @State private var note: String = ""
    @State private var expenseDate: Date = Date()
    @State private var payer: [Expense.Participant] = []
    @State private var participants: [Expense.Participant] = []
    
    // 샘플 참가자 데이터
    private let availableParticipants = [
        Expense.Participant(memberId: "1", name: "홍석현"),
        Expense.Participant(memberId: "2", name: "김철수"),
        Expense.Participant(memberId: "3", name: "이영희"),
        Expense.Participant(memberId: "4", name: "박민수")
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 24) {
                    // 금액 입력
                    AmountInputField(amount: $amount)
                    
                    // 카테고리 선택
                    CategorySelector(selectedCategory: $selectedCategory)
                    
                    // 제목 입력
                    TextInputField(
                        label: "제목",
                        placeholder: "지출 제목을 입력하세요",
                        text: $title
                    )
                    
                    // 메모 입력
                    TextInputField(
                        label: "메모",
                        placeholder: "메모를 입력하세요",
                        text: $note,
                        isOptional: true
                    )
                    
                    // 날짜 선택
                    DatePickerField(label: "날짜", date: $expenseDate)
                    
                    // 지불자 선택
                    ParticipantSelector(
                        label: "지불자",
                        selectedParticipants: $payer,
                        availableParticipants: availableParticipants,
                        multipleSelection: false
                    )
                    
                    // 참가자 선택
                    ParticipantSelector(
                        label: "참가자",
                        selectedParticipants: $participants,
                        availableParticipants: availableParticipants,
                        multipleSelection: true
                    )
                    
                    // 하단 여백 (버튼 공간 확보)
                    Spacer()
                        .frame(height: 80)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            
            // 저장 버튼 (하단 고정)
            VStack(spacing: 0) {
                Divider()
                
                PrimaryButton(title: "저장") {
                    saveExpense()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)
            }
        }
        .navigationTitle("지출 기록")
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