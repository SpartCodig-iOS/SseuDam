//
//  FormLabel.swift
//  ExpenseFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem

struct FormLabel: View {
    let title: String
    let isRequired: Bool
    
    init(_ title: String, isRequired: Bool = true) {
        self.title = title
        self.isRequired = isRequired
    }
    
    var body: some View {
        HStack(spacing: 2) {
            if isRequired {
                Text("*")
                    .foregroundStyle(.red)
                    .font(.system(size: 14, weight: .medium))
            }
            Text(title)
                .foregroundStyle(Color.primary800) // DesignSystem Color
                .font(.system(size: 14, weight: .bold))
        }
    }
}
