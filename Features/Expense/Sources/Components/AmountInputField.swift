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
    
    public init(amount: Binding<String>, currency: String = "JPY") {
        self._amount = amount
        self.currency = currency
    }
    
    private var convertedAmount: String {
        guard let value = Double(amount), value > 0 else { return "-" }
        // TODO: 실제 환율 데이터 연동 필요 (현재 1 JPY = 9 KRW 가정)
        let exchangeRate = 9.0
        let converted = value * exchangeRate
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: converted)) ?? "-"
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormLabel("지출 금액")
            
            HStack(spacing: 8) {
                InputContainer {
                    TextField("-", text: $amount)
                        .font(.system(size: 16))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
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
                
                Text("₩\(convertedAmount)")
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
