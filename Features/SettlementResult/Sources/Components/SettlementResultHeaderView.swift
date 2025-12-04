//
//  SettlementResultHeaderView.swift
//  SettlementResultFeature
//
//  Created by 홍석현 on 12/4/25.
//

import SwiftUI
import DesignSystem

struct SettlementResultHeaderView: View {
    let totalExpenseAmount: Int
    let myExpenseAmount: Int
    let totalPersonCount: Int

    private var averageExpensePerPerson: Int {
        totalPersonCount > 0 ? totalExpenseAmount / totalPersonCount : 0
    }

    var body: some View {
        VStack(spacing: 16) {
            // 총 지출
            VStack(spacing: 8) {
                Text("총 지출")
                    .font(.app(.body, weight: .medium))
                    .foregroundStyle(Color.gray7)

                Text("₩\(totalExpenseAmount.formatted())")
                    .font(.app(.title1, weight: .semibold))
                    .foregroundStyle(Color.black)
            }
            .padding(12)

            // 통계 정보
            HStack(spacing: 0) {
                StatItemView(
                    label: "내 지출",
                    value: "₩\(myExpenseAmount.formatted())"
                )

                StatItemView(
                    label: "인원 수",
                    value: "\(totalPersonCount)명"
                )

                StatItemView(
                    label: "1인 평균",
                    value: "₩\(averageExpensePerPerson.formatted())"
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
        totalExpenseAmount: 1245000,
        myExpenseAmount: 520000,
        totalPersonCount: 5
    )
}
