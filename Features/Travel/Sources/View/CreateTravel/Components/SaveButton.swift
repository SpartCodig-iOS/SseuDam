//
//  SaveButton.swift
//  TravelFeature
//
//  Created by 김민희 on 11/24/25.
//

import SwiftUI
import DesignSystem

struct SaveButton: View {
    var isEnabled: Bool
    var action: () -> Void

    var body: some View {
        Button {
            action()
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
        .disabled(!isEnabled)
    }
}

#Preview {
    SaveButton(isEnabled: true)
}
