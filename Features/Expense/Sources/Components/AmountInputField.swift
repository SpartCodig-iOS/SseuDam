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
    
    public init(amount: Binding<String>, currency: String = "JYP") {
        self._amount = amount
        self.currency = currency
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormLabel("지출 금액")
            
            HStack(spacing: 8) {
                InputContainer {
                    TextField("", text: $amount)
                        .font(.system(size: 16))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                    
                    Text("-")
                        .foregroundStyle(.gray)
                }
                
                Text(currency)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.primary800)
            }
            
            HStack {
                Text("KRW 환산 금액")
                    .font(.system(size: 14))
                    .foregroundStyle(.blue)
                
                Spacer()
                
                Text("₩-")
                    .font(.system(size: 14))
                    .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    @Previewable @State var amount = ""
    AmountInputField(amount: $amount)
        .padding()
}
