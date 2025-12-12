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
        HStack(alignment: .top) {
            // 지출 제목
            Text(expense.title)
                .font(.app(.body, weight: .medium))
                .foregroundStyle(Color.black)

            Spacer()

            // 내 부담 금액 + 계산식
            VStack(alignment: .trailing, spacing: 4) {
                Text("₩\(Int(expense.shareAmount).formatted())")
                    .font(.app(.body, weight: .medium))
                    .foregroundStyle(Color.black)

                Text("₩\(Int(expense.amount).formatted()) ÷ \(expense.participantCount)")
                    .font(.app(.caption2, weight: .medium))
                    .foregroundStyle(Color.gray6)
            }
        }
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
