//
//  MyCardView.swift
//  MemberFeature
//
//  Created by 김민희 on 12/9/25.
//

import Foundation
import SwiftUI
import DesignSystem

struct MyCardView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary100)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primary100, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: -4, y: 0)

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appWhite)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primary100, lineWidth: 1)
                )
                .offset(x: 3)

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
                        Text("김민수")
                            .font(.app(.body, weight: .medium))
                            .foregroundStyle(Color.appBlack)

                        Text("관리자")
                            .font(.app(.caption2, weight: .medium))
                            .foregroundStyle(Color.gray7)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.primary100)
                            )
                    }

                    Text("yh@example.com")
                        .font(.app(.body, weight: .medium))
                        .tint(Color.gray6)
                }
            }
            .padding(20)

        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    MyCardView()
}
