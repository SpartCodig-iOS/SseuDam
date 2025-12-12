//
//  PaymentSectionView.swift
//  SettlementResultFeature
//
//  Created by 홍석현 on 12/4/25.
//

import SwiftUI
import DesignSystem

struct PaymentSectionView: View {
    let title: String
    let totalAmount: Double
    let amountColor: Color
    let payments: [PaymentItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 섹션 헤더
            Text(title)
                .font(.app(.title3, weight: .medium))
                .foregroundStyle(Color.black)

            // 결제 리스트
            VStack(spacing: 12) {
                ForEach(payments) { payment in
                    PaymentRowView(payment: payment)
                }
            }

            Divider()
                .foregroundStyle(Color.gray2)

            HStack {
                Text("총 금액")
                    .foregroundStyle(Color.black)

                Spacer()

                Text("₩\(Int(totalAmount).formatted())")
                    .foregroundStyle(amountColor)
            }
            .font(.app(.title3, weight: .semibold))
        }
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray1, lineWidth: 1)
        )
    }
}

// MARK: - Payment Row View
private struct PaymentRowView: View {
    let payment: PaymentItem

    var body: some View {
        HStack(spacing: 12) {
            Image(asset: .profile)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)

            Text(payment.name)
                .font(.app(.title3, weight: .medium))
                .foregroundStyle(Color.black)

            Spacer()

            Text("₩\(Int(payment.amount).formatted())")
                .font(.app(.body, weight: .medium))
                .foregroundStyle(Color.black)
        }
    }
}

// MARK: - Payment Item Model
struct PaymentItem: Identifiable {
    let id: String
    let name: String
    let amount: Int
}

// MARK: - Preview
#Preview {
    VStack(spacing: 24) {
        PaymentSectionView(
            title: "지급 예정 금액",
            totalAmount: 90000,
            amountColor: Color.red,
            payments: [
                PaymentItem(id: "1", name: "이영희", amount: 45000),
                PaymentItem(id: "2", name: "이영민", amount: 45000)
            ]
        )

        PaymentSectionView(
            title: "수령 예정 금액",
            totalAmount: 100000,
            amountColor: Color.primary500,
            payments: [
                PaymentItem(id: "3", name: "박철수", amount: 50000),
                PaymentItem(id: "4", name: "박철", amount: 50000)
            ]
        )
    }
    .background(Color.primary50)
}
