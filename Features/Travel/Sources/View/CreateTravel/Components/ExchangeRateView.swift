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
    @Binding var selectedCurrency: String?
    @Binding var rate: String
    @State private var isCurrencyDialogPresented = false

    var onCurrencyFieldTapped: () -> Void = { }

    var body: some View {
        VStack(spacing: 20) {
            if currency.count == 1 {
                InputTextField(
                    text: Binding(
                        get: { selectedCurrency ?? "" },
                        set: { _ in }
                    ),
                    title: "화폐 선택",
                    essential: true,
                    placeholder: "",
                    isEnabled: false
                )

            } else if currency.count > 1 {
                SelectField(
                    title: "화폐 선택",
                    essential: true,
                    placeholder: "화폐를 선택해주세요",
                    value: selectedCurrency,
                    onTap: {
                        onCurrencyFieldTapped()
                        isCurrencyDialogPresented = true
                    }
                )
                .confirmationDialog(
                    "화폐 선택",
                    isPresented: $isCurrencyDialogPresented,
                    titleVisibility: .visible
                ) {
                    ForEach(currency, id: \.self) { cur in
                        Button(cur) {
                            selectedCurrency = cur
                        }
                    }
                }
            }

            ExchangeRateInputField(
                label: "환율 설정",
                baseAmount: "1 \(selectedCurrency ?? "")",
                currency: "KRW",
                rate: $rate
            )
        }
        .onAppear {
            if selectedCurrency == nil {
                selectedCurrency = currency.first
            }
        }
    }
}

#Preview {
    ExchangeRateView(
        currency: .constant(["USD", "ARS"]),
        selectedCurrency: .constant("USD"),
        rate: .constant("")
    )
}
