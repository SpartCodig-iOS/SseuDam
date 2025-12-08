//
//  FormLabel.swift
//  SaveExpenseFeature
//
//  Created by SseuDam on 2025.ㅂ
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
                    .font(.app(.title3, weight: .medium))
            }
            Text(title)
                .foregroundStyle(Color.black)
                .font(.app(.title3, weight: .medium))
        }
    }
}
