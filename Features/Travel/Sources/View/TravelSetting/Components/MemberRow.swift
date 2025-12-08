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
    let isEditing: Bool
    let onDelegateOwner: () -> Void
    let onDelete: () -> Void

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

            // 편집 모드
            if isEditing && !isOwner && !isMe {
                HStack(spacing: 0) {
                    Button(action: onDelegateOwner) {
                        Text("관리자")
                            .underline(true, color: Color.gray7)
                            .font(.app(.caption1, weight: .medium))
                            .foregroundColor(.gray7)
                    }

                    Divider()
                        .frame(width: 1, height: 12)
                        .foregroundColor(.gray1)
                        .padding(.horizontal, 4)

                    Button(action: onDelete) {
                        Text("삭제")
                            .underline(true, color: .red)
                            .font(.app(.caption1, weight: .medium))
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}
