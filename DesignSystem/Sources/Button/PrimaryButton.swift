//
//  PrimaryButton.swift
//  DesignSystem
//
//  Created by SseuDam on 2025.
//

import SwiftUI

public struct PrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    public init(
        title: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.app(.title3, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(isEnabled ? Color.primary500 : Color.gray2)
                .cornerRadius(8)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    PrimaryButton(title: "저장") {
        print("Button tapped")
    }
    .padding()
}
