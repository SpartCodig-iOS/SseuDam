//
//  TravelManageView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/30/25.
//

import SwiftUI
import DesignSystem

// MARK: - 여행 관리 섹션
struct TravelManageView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            SectionHeader(title: "여행 관리")

            VStack(spacing: 0) {
                Button(action: {}) {
                    HStack {
                        Image(assetName: "logout")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)

                        Text("여행 나가기")
                            .font(.app(.title3))

                        Spacer()
                    }
                    .foregroundStyle(Color.appBlack)
                }

                Divider()
                    .foregroundStyle(Color.gray1)
                    .padding(.vertical, 12)

                Button(action: {}) {
                    HStack {
                        Image(assetName: "trash")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)

                        Text("여행 삭제")
                            .font(.app(.title3))

                        Spacer()
                    }
                    .foregroundStyle(.red)
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.appWhite)))
        }
    }
}

#Preview {
    TravelManageView()
}
