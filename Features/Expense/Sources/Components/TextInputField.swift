//
//  TextInputField.swift
//  ExpenseFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem

public struct TextInputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let isOptional: Bool
    
    public init(
        label: String,
        placeholder: String = "",
        text: Binding<String>,
        isOptional: Bool = false
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.isOptional = isOptional
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.primary800)
                
                if isOptional {
                    Text("(선택)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.gray2)
                }
            }
            
            TextField(placeholder, text: $text)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.primary800)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray2.opacity(0.3))
                .cornerRadius(12)
        }
    }
}

#Preview {
    @Previewable @State var title = ""
    @Previewable @State var note = ""
    
    VStack(spacing: 16) {
        TextInputField(
            label: "제목",
            placeholder: "지출 제목을 입력하세요",
            text: $title
        )
        
        TextInputField(
            label: "메모",
            placeholder: "메모를 입력하세요",
            text: $note,
            isOptional: true
        )
    }
    .padding()
}
