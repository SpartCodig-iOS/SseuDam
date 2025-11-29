//
//  ExchangeRateInputField.swift
//  TravelFeature
//
//  Created by 김민희 on 11/21/25.
//

import SwiftUI

struct ExchangeRateInputField: View {
    var label: String
    var baseAmount: String
    var currency: String

    @Binding var rate: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.app(.title3, weight: .medium))

            HStack {
                Text(baseAmount)
                    .font(.app(.body, weight: .medium))
                    .foregroundColor(Color.appBlack)

                Spacer()

                HStack(spacing: 4) {
                    TextField("0", text: $rate)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 130)
                        .font(.app(.body, weight: .medium))
                        .foregroundColor(Color.appBlack)

                    Text(currency)
                        .font(.app(.body, weight: .medium))
                        .foregroundColor(Color.appBlack)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 13)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray2, lineWidth: 1)
            )
        }
    }
}

#Preview {
    ExchangeRateInputField(label: "환율 설정", baseAmount: "1 USD", currency: "KRW", rate: .constant(""))
}
