//
//  CreateTravelView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/21/25.
//

import SwiftUI

struct CreateTravelView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var title: String
    @Binding var currency: [String]
    @Binding var rate: String
    @State private var selectedCountry: String? = nil
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil

    private var isSaveEnabled: Bool {
        guard !title.isEmpty else { return false }
        guard startDate != nil, endDate != nil else { return false }
        guard let country = selectedCountry, !country.isEmpty else { return false }

        if country == "한국" {
            return true
        }
        return !currency.isEmpty && !rate.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Button {
                    dismiss()
                } label: {
                    Image(assetName: "chevronLeft")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .foregroundColor(Color.appBlack)
                }

                Text("새 여행 만들기")
                    .font(.app(.title1, weight: .semibold))
                    .foregroundStyle(Color.appBlack)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)

            ScrollView {
                VStack(spacing: 16) {
                    TravelInfoView(
                        title: $title,
                        selectedCountry: $selectedCountry,
                        startDate: $startDate,
                        endDate: $endDate
                    )

                    if selectedCountry != "한국" && selectedCountry != nil {
                        ExchangeRateView(currency: $currency, rate: $rate)
                    }
                }
                .padding(.horizontal, 16)
            }
            SaveButton(isEnabled: isSaveEnabled)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
        .background(Color.primary50)
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(false)
    }
}

#Preview {
    CreateTravelView(title: .constant(""), currency: .constant([""]), rate: .constant(""))
}
