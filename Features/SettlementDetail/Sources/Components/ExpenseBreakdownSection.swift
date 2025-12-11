//
//  ExpenseBreakdownSection.swift
//  SettlementDetailFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem
import Domain

struct ExpenseBreakdownSection: View {
    let title: String
    let totalAmount: Double
    let expenses: [ExpenseDetail]
    let showEmpty: Bool

    // 날짜 오름차순 정렬된 지출 목록
    private var sortedExpenses: [ExpenseDetail] {
        expenses.sorted { $0.expenseDate < $1.expenseDate }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 섹션 헤더
            HStack {
                Text(title)
                    .font(.app(.body, weight: .semibold))
                    .foregroundStyle(Color.black)

                Spacer()

                Text("₩\(Int(totalAmount).formatted())")
                    .font(.app(.title3, weight: .semibold))
                    .foregroundStyle(Color.primary500)
            }

            // 지출 내역
            if expenses.isEmpty && showEmpty {
                Text("결제한 내역이 없습니다")
                    .font(.app(.caption1, weight: .medium))
                    .foregroundStyle(Color.gray7)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 8) {
                    ForEach(sortedExpenses) { expense in
                        ExpenseRow(expense: expense)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.primary50)
        .cornerRadius(12)
    }
}

#Preview("지출이 있는 경우") {
    let calendar = Calendar.current
    let today = Date()
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

    return ExpenseBreakdownSection(
        title: "결제한 금액",
        totalAmount: 280000,
        expenses: [
            ExpenseDetail(
                id: "1",
                title: "호텔",
                amount: 120000,
                shareAmount: 40000,
                participantCount: 3,
                expenseDate: twoDaysAgo
            ),
            ExpenseDetail(id: "2", title: "저녁식사", amount: 60000, shareAmount: 30000, participantCount: 2, expenseDate: yesterday),
            ExpenseDetail(
                id: "3",
                title: "커피",
                amount: 100000,
                shareAmount: 33333,
                participantCount: 3,
                expenseDate: today
            )
        ],
        showEmpty: true
    )
    .padding(16)
    .background(Color.white)
}

#Preview("지출이 없는 경우") {
    let calendar = Calendar.current
    let today = Date()
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

    return ExpenseBreakdownSection(
        title: "결제한 금액",
        totalAmount: 0,
        expenses: [],
        showEmpty: true
    )
    .padding(16)
    .background(Color.white)
}

#Preview("부담 금액") {
    let calendar = Calendar.current
    let today = Date()
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

    return ExpenseBreakdownSection(
        title: "부담 금액",
        totalAmount: 226773,
        expenses: [
            ExpenseDetail(
                id: "1",
                title: "호텔",
                amount: 120000,
                shareAmount: 40000,
                participantCount: 3,
                expenseDate: twoDaysAgo
            ),
            ExpenseDetail(
                id: "2",
                title: "저녁식사",
                amount: 60000,
                shareAmount: 30000,
                participantCount: 2,
                expenseDate: yesterday
            ),
            ExpenseDetail(
                id: "3",
                title: "커피",
                amount: 100000,
                shareAmount: 33333,
                participantCount: 3,
                expenseDate: today
            )
        ],
        showEmpty: false
    )
    .padding(16)
    .background(Color.white)
}
