//
//  SectionHeaderRow.swift
//  SettlementDetailFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem

struct SectionHeaderRow: View {
    let title: String
    let amount: Double

    var body: some View {
        HStack {
            Text(title)
                .font(.app(.caption1, weight: .semibold))
                .foregroundStyle(Color.black)

            Spacer()

            Text("₩\(Int(amount).formatted())")
                .font(.app(.body, weight: .semibold))
                .foregroundStyle(Color.primary500)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SectionHeaderRow(title: "결제한 금액", amount: 400000)
        SectionHeaderRow(title: "부담 금액", amount: 120000)
    }
    .padding(16)
    .background(Color.white)
}
