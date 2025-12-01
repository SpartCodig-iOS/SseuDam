//
//  DateFieldView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/24/25.
//

import SwiftUI
import DesignSystem

struct DateFieldView: View {
    let title: String
    let date: Date?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(assetName: "calendar")
                    .foregroundColor(Color.gray7)

                Text(dateFormatters(date))
                    .font(.app(.body, weight: .medium))
                    .foregroundColor(date == nil ? .gray4 : .appBlack)

                Spacer()
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray2, lineWidth: 1)
            )
        }
    }
}

private func dateFormatters(_ date: Date?) -> String {
    guard let date else { return "yyyy.mm.dd" }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM.dd"
    return formatter.string(from: date)
}
