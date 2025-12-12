//
//  DateHeaderRow.swift
//  SettlementDetailFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem

struct DateHeaderRow: View {
    let date: Date

    var body: some View {
        Text(formatDate(date))
            .font(.app(.caption1, weight: .medium))
            .foregroundStyle(Color.gray6)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 0) {
        DateHeaderRow(date: Date())
        DateHeaderRow(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
    }
    .padding(16)
    .background(Color.white)
}
