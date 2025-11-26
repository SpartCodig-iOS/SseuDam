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
    
    public init(
        label: String,
        placeholder: String = "",
        text: Binding<String>
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormLabel(label)
            
            InputContainer {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
            }
        }
    }
}

#Preview {
    @Previewable @State var title = ""
    TextInputField(
        label: "지출 제목",
        placeholder: "ex) 점심 식사",
        text: $title
    )
    .padding()
}
