//
//  MemberRow.swift
//  TravelFeature
//
//  Created by 김민희 on 11/30/25.
//

import SwiftUI
import DesignSystem

struct MemberRow: View {
    let name: String
    let isMe: Bool
    let isOwner: Bool

    var body: some View {
        HStack(spacing: 0) {
            Image(assetName: "profile")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .foregroundStyle(Color.primary500)
                .background(
                    Circle()
                        .fill(Color.primary50)
                )

            Text(name)
                .font(.app(.body, weight: .medium))
                .foregroundColor(.appBlack)
                .padding(.leading, 8)

            Spacer()

            // "나" 태그
            if isMe {
                Text("나")
                    .font(.app(.body, weight: .medium))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 6)
                    .foregroundStyle(Color.gray7)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.primary100)
                    )
            }

            // "관리자" 태그
            if !isMe && isOwner {
                Text("관리자")
                    .font(.app(.body, weight: .medium))
                    .foregroundStyle(Color.gray7)
            }
        }
    }
}
