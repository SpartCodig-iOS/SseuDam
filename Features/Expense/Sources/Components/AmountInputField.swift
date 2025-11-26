//
//  AmountInputField.swift
//  ExpenseFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem

public struct AmountInputField: View {
    @Binding var amount: String
    let currency: String
    
    public init(amount: Binding<String>, currency: String = "₩") {
        self._amount = amount
        self.currency = currency
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("금액")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.primary800)
            
            HStack(spacing: 4) {
                Text(currency)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(Color.primary800)
                
                TextField("0", text: $amount)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(Color.primary800)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray2.opacity(0.3))
            .cornerRadius(12)
        }
    }
}

#Preview {
    @Previewable @State var amount = "12000"
    
    AmountInputField(amount: $amount)
        .padding()
}
