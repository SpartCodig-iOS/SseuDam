//
//  MemberCardView.swift
//  MemberFeature
//
//  Created by 김민희 on 12/9/25.
//

import Foundation
import SwiftUI
import DesignSystem

struct MemberCardView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray2)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray2, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: -4, y: 0)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appWhite)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray2, lineWidth: 1)
                )
                .offset(x: 3)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(assetName: "profile")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .foregroundStyle(Color.primary500)
                        .background(
                            Circle()
                                .fill(Color.primary50)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text("이영희")
                                .font(.app(.body, weight: .medium))
                                .foregroundStyle(Color.appBlack)

                            Text("참여자")
                                .font(.app(.caption2, weight: .medium))
                                .foregroundStyle(Color.gray7)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray2, lineWidth: 1)
                                )
                        }

                        Text("yh@example.com")
                            .font(.app(.body, weight: .medium))
                            .tint(Color.gray6)
                    }
                }

                HStack(spacing: 4) {
                    Spacer()

                    Button {
                        print("관리자 지정")
                    } label: {
                        Text("관리자 지정")
                            .font(.app(.caption1, weight: .medium))
                            .foregroundStyle(Color.gray7)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.primary100)
                            )
                    }

                    Button {
                        print("삭제")
                    } label: {
                        Text("삭제")
                            .font(.app(.caption1, weight: .medium))
                            .foregroundStyle(Color.error)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.error.opacity(0.2))
                            )
                    }
                }
            }
            .padding(20)

        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    MemberCardView()
}
