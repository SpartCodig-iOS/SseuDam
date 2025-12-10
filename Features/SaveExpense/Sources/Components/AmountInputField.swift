//
//  AmountInputField.swift
//  SaveExpenseFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem

public struct AmountInputField: View {
    @Binding var amount: String
    let baseCurrency: String
    let convertedAmountKRW: String
    
    public init(
        amount: Binding<String>,
        baseCurrency: String = "",
        convertedAmountKRW: String = ""
    ) {
        self._amount = amount
        self.baseCurrency = baseCurrency
        self.convertedAmountKRW = convertedAmountKRW
    }
    
    private var shouldShowConversion: Bool {
        baseCurrency != "KRW"
    }
    
    // 천단위 콤마 표시용 (소수점 제거)
    private var formattedAmount: String {
        guard let number = Double(amount.replacingOccurrences(of: ",", with: "")) else {
            return amount
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0  // 소수점 제거
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? amount
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormLabel("지출 금액")
            
            HStack(spacing: 8) {
                InputContainer {
                    TextField("-", text: Binding(
                        get: { formattedAmount },
                        set: { newValue in
                            // 콤마 제거하고 숫자만 필터링
                            let filtered = newValue.replacingOccurrences(of: ",", with: "").filter { $0.isNumber }
                            amount = filtered
                        }
                    ))
                    .font(.app(.body, weight: .medium))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                }
                
                Text(baseCurrency.isEmpty ? "-" : baseCurrency)
                    .font(.app(.body, weight: .medium))
                    .foregroundStyle(Color.primary800)
            }
            
            if shouldShowConversion {
                HStack {
                    Text("KRW 환산 금액")
                        .font(.app(.body, weight: .medium))
                    
                    Spacer()
                    
                    Text("₩\(convertedAmountKRW)")
                        .font(.app(.body, weight: .medium))
                }
                .foregroundStyle(Color.primary500)
            }
        }
    }
}

#Preview("외국 통화") {
    @Previewable @State var amount = "1000"
    AmountInputField(
        amount: $amount,
        baseCurrency: "JPY",
        convertedAmountKRW: "9,000"
    )
    .padding()
}

#Preview("한국 통화") {
    @Previewable @State var amount = "1000"
    
    AmountInputField(
        amount: $amount,
        baseCurrency: "KRW",
        convertedAmountKRW: ""
    )
    .padding()
}
