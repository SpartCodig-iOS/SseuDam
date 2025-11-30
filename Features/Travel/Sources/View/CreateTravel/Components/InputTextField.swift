//
//  InputTextField.swift
//  TravelFeature
//
//  Created by 김민희 on 11/21/25.
//

import SwiftUI
import DesignSystem

struct InputTextField: View {
    @Binding var text: String
    let title: String
    let essential: Bool
    let placeholder: String
    let isEnabled: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 2) {
                if essential {
                    Text("*")
                        .font(.app(.title3, weight: .medium))
                        .foregroundColor(.red)
                }

                Text(title)
                    .font(.app(.title3, weight: .medium))
                    .foregroundStyle(Color.appBlack)
            }

            TextField(placeholder, text: $text)
                .font(.app(.body, weight: .medium))
                .foregroundColor(Color.appBlack)
                .padding(.horizontal, 10)
                .padding(.vertical, 13)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray2, lineWidth: 1)
                )
                .disabled(!isEnabled)
        }
    }
}

#Preview {
    InputTextField(text: .constant(""), title: "여행 이름", essential: true, placeholder: "텍스트 입력", isEnabled: true)
}
