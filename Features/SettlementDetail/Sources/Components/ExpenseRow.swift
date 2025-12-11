//
//  ExpenseRow.swift
//  SettlementDetailFeature
//
//  Created by 홍석현 on 12/11/25.
//

import SwiftUI
import Domain

struct ExpenseRow: View {
    let expense: ExpenseDetail

    var body: some View {
        HStack(spacing: 8) {
            // 지출 제목 + 날짜
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.app(.body, weight: .medium))
                    .foregroundStyle(Color.black)

                Text(formatDate(expense.expenseDate))
                    .font(.app(.caption2, weight: .medium))
                    .foregroundStyle(Color.gray7)
            }

            Spacer()

            // 내 부담 금액
            VStack(alignment: .trailing, spacing: 2) {
                Text("₩\(Int(expense.shareAmount).formatted())")
                    .font(.app(.body, weight: .semibold))
                    .foregroundStyle(Color.black)

                Text("(전체 ₩\(Int(expense.amount).formatted()) ÷ \(expense.participantCount))")
                    .font(.app(.caption2, weight: .medium))
                    .foregroundStyle(Color.gray7)
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}


#Preview {
    ExpenseRow(expense: ExpenseDetail(
        id: "3",
        title: "커피",
        amount: 100000,
        shareAmount: 33333,
        participantCount: 3,
        expenseDate: .now
    ))
}
