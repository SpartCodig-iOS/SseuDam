//
//  StatItemView.swift
//  SettlementResultFeature
//
//  Created by 홍석현 on 12/16/25.
//

import SwiftUI
import DesignSystem

struct StatItemView: View {
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
    HStack(spacing: 0) {
        StatItemView(label: "내 지출", value: "52만원")
        StatItemView(label: "인원 수", value: "5명")
        StatItemView(label: "1인 평균", value: "24만 9,000원")
    }
    .padding()
}
