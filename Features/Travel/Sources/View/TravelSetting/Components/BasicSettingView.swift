//
//  BasicSettingView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/30/25.
//

import SwiftUI
import DesignSystem

// MARK: - 기본 설정 섹션
struct BasicSettingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            SectionHeader(title: "기본 설정")

            VStack(alignment: .leading, spacing: 0) {

                InfoRow(title: "여행 이름", value: "오사카 여행", imageName: nil)

                Divider()
                    .foregroundStyle(Color.gray1)
                    .padding(.vertical, 16)

                HStack(alignment: .center, spacing: 0) {
                    InfoRow(title: "시작일", value: "2024.12.20", imageName: nil)
                    Spacer()

                    Divider()
                        .frame(width: 1, height: 46)
                        .foregroundStyle(Color.gray1)

                    InfoRow(title: "종료일", value: "2024.12.25", imageName: nil)
                    Spacer()
                }

                Divider()
                    .foregroundStyle(Color.gray1)
                    .padding(.vertical, 16)

                InfoRow(title: "국가", value: "일본", imageName: nil)

                Divider()
                    .foregroundStyle(Color.gray1)
                    .padding(.vertical, 16)

                InfoRow(title: "화폐", value: "JYP", imageName: nil)

                Divider()
                    .foregroundStyle(Color.gray1)
                    .padding(.vertical, 16)

                InfoRow(title: "초대 코드", value: "1A1A1A", imageName: "files")
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.appWhite)))
        }
    }
}

#Preview {
    BasicSettingView()
}
