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

    var body: some View {
        VStack(spacing: 8) {
            Text("총 지출")
                .font(.app(.body, weight: .medium))
                .foregroundStyle(Color.gray7)

            Text(totalExpenseAmount)
                .font(.app(.title1, weight: .semibold))
                .foregroundStyle(Color.black)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    SettlementResultHeaderView(
        totalExpenseAmount: "124만 5,000원"
    )
}
