//
//  ExchangeRateView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/21/25.
//

import SwiftUI
import DesignSystem

struct ExchangeRateView: View {
    @Binding var currency: [String]
    @Binding var rate: String
    var body: some View {
        VStack(spacing: 20) {
            if currency.count == 1 {
                InputTextField(
                    text: $currency.first ?? .constant(""),
                    title: "화폐 선택",
                    essential: false,
                    placeholder: "화폐를 선택해주세요",
                    isEnabled: false
                )
            } else if currency.count > 1 {
                SelectField(title: "화폐 선택", essential: false, placeholder: "화폐를 선택해주세요", value: currency.first)
            }

            ExchangeRateInputField(
                label: "환율 설정",
                baseAmount: "1 JPY",
                currency: "KRW",
                rate: $rate
            )
        }
    }
}

#Preview {
    ExchangeRateView(currency: .constant(["JYP"]), rate: .constant(""))
}
