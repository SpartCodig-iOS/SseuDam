//
//  SaveButton.swift
//  TravelFeature
//
//  Created by 김민희 on 11/24/25.
//

import SwiftUI
import DesignSystem

struct SaveButton: View {
    var body: some View {
        Button {
            print("저장")
        } label: {
            Text("저장")
                .font(.app(.title3, weight: .semibold))
                .foregroundStyle(Color.appWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(Color.primary500)
                )
        }
    }
}

#Preview {
    SaveButton()
}
