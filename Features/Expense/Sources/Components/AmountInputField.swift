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
        baseCurrency != "KRW" && !baseCurrency.isEmpty && !convertedAmountKRW.isEmpty
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormLabel("지출 금액")

            HStack(spacing: 8) {
                InputContainer {
                    TextField("-", text: $amount)
                        .font(.app(.body, weight: .medium))
                        .keyboardType(.decimalPad)
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
