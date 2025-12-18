//
//  ExpenseCardView.swift
//  ExpenseListFeature
//
//  Created by 홍석현 on 11/28/25.
//

import SwiftUI
import Domain
import DesignSystem

public struct ExpenseCardView: View {
    let expense: Expense

    public init(expense: Expense) {
        self.expense = expense
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    ExpenseCategoryTag(category: expense.category)
                    
                    Text(expense.title)
                        .font(.app(.title3, weight: .medium))
                        .foregroundStyle(.black)
                }
                
                Spacer()

                // 금액 정보
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₩\(expense.formattedConvertedAmount())")
                        .font(.app(.title3, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(.black)

                    Text("\(expense.currency) \(expense.formattedAmount())")
                        .font(.app(.caption1, weight: .medium))
                        .lineLimit(1)
                }
            }

            Divider()
                .background(Color.gray1)

            // 하단: 결제자 & 인원
            HStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(asset: .receipt)
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text(expense.payer.name)
                        .lineLimit(1)
                }

                // 구분선 (|)
                Rectangle()
                    .fill(Color.gray1)
                    .frame(width: 1, height: 15)

                HStack(spacing: 4) {
                    Image(asset: .users)
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text("\(expense.participants.count)명")
                }
            }
            .font(.app(.caption1, weight: .medium))
            .foregroundStyle(Color.gray7)
        }
        .padding(20)
        .background(Color.primary50)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray1, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        ExpenseCardView(expense: .mock1)
            .padding()
    }
}
