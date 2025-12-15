//
//  SettlementResultHeaderView.swift
//  SettlementResultFeature
//
//  Created by 홍석현 on 12/4/25.
//

import SwiftUI
import DesignSystem

struct SettlementResultHeaderView: View {
    let totalExpenseAmount: String
    let myExpenseAmount: String
    let totalPersonCount: Int
    let averageExpensePerPerson: String

    var body: some View {
        VStack(spacing: 16) {
            // 총 지출
            VStack(spacing: 8) {
                Text("총 지출")
                    .font(.app(.body, weight: .medium))
                    .foregroundStyle(Color.gray7)

                Text(totalExpenseAmount)
                    .font(.app(.title1, weight: .semibold))
                    .foregroundStyle(Color.black)
            }
            .padding(12)

            // 통계 정보
            HStack(spacing: 0) {
                StatItemView(
                    label: "내 지출",
                    value: myExpenseAmount
                )

                StatItemView(
                    label: "인원 수",
                    value: "\(totalPersonCount)명"
                )

                StatItemView(
                    label: "1인 평균",
                    value: averageExpensePerPerson
                )
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Stat Item View
private struct StatItemView: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.app(.caption1, weight: .semibold))
                .foregroundStyle(Color.gray7)

            Text(value)
                .font(.app(.title3, weight: .semibold))
                .foregroundStyle(Color.black)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SettlementResultHeaderView(
        totalExpenseAmount: "124만 5,000원",
        myExpenseAmount: "52만원",
        totalPersonCount: 5,
        averageExpensePerPerson: "24만 9,000원"
    )
}
