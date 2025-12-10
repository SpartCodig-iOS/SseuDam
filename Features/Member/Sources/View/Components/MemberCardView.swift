//
//  MemberCardView.swift
//  MemberFeature
//
//  Created by 김민희 on 12/9/25.
//

import Foundation
import SwiftUI
import DesignSystem
import Domain

struct MemberCardView: View {
    let member: TravelMember

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray2)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray2, lineWidth: 1)
                )

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
                            Text(member.name)
                                .font(.app(.body, weight: .medium))
                                .foregroundStyle(Color.appBlack)

                            Text(member.role.rawValue)
                                .font(.app(.caption2, weight: .medium))
                                .foregroundColor(Color.gray7)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray2, lineWidth: 1)
                                )

                            Spacer()

                            Button {
                                print("삭제")
                            } label: {
                                Image(assetName: "trash")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                    .foregroundStyle(Color.gray6)
                            }
                        }

                        Text(member.email ?? "")
                            .font(.app(.body, weight: .medium))
                            .tint(Color.gray6)
                    }
                }

                HStack(spacing: 4) {
                    Button {
                        print("관리자 지정")
                    } label: {
                        Text("관리자 지정")
                            .font(.app(.caption1, weight: .medium))
                            .foregroundStyle(Color.gray7)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.primary100)
                            )
                    }
                }
            }
            .padding(20)

        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

