//
//  MemberSettingView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/30/25.
//

import SwiftUI

// MARK: - 멤버 섹션
struct MemberSettingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            SectionHeader(title: "멤버")

            VStack(spacing: 0) {
                MemberRow(name: "김민수", isMe: true)

                Divider()
                    .foregroundStyle(Color.gray1)
                    .padding(.vertical, 12)

                MemberRow(name: "이영희")

                Divider()
                    .foregroundStyle(Color.gray1)
                    .padding(.vertical, 12)

                MemberRow(name: "박철수")
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.appWhite)))
        }
    }
}

#Preview {
    MemberSettingView()
}
