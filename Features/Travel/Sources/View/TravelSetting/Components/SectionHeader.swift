//
//  SectionHeader.swift
//  TravelFeature
//
//  Created by 김민희 on 11/30/25.
//

import SwiftUI
import DesignSystem

struct SectionHeader: View {
    let title: String
    @Binding var isEditing: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.app(.title3, weight: .medium))
                .foregroundStyle(Color.appBlack)
            Spacer()

            Button {
                withAnimation {
                    isEditing.toggle()
                }
            } label: {
                Text(isEditing ? "완료" : "수정")
                    .underline(true, color: Color.gray7)
                    .font(.app(.caption1, weight: .medium))
                    .foregroundColor(Color.gray7)
            }
        }
    }
}
