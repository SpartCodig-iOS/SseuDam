//
//  PrimaryButton.swift
//  ExpenseFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem

public struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.primary500)
                .cornerRadius(12)
        }
    }
}

#Preview {
    PrimaryButton(title: "저장") {
        print("Button tapped")
    }
    .padding()
}
