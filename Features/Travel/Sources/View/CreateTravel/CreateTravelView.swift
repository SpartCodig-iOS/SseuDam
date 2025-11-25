//
//  CreateTravelView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/21/25.
//

import SwiftUI
import ComposableArchitecture

struct CreateTravelView: View {
    @Bindable var store: StoreOf<TravelCreateFeature>
    @Environment(\.dismiss) private var dismiss

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
                        title: $store.title,
                        selectedCountry: $store.selectedCountry,
                        startDate: $store.startDate,
                        endDate: $store.endDate
                    )

                    if store.selectedCountry != "한국",
                       store.selectedCountry != nil {
                        ExchangeRateView(
                            currency: $store.currency,
                            rate: $store.rate
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            SaveButton(isEnabled: store.isSaveEnabled) {
                store.send(.saveButtonTapped)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.primary50)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CreateTravelView(title: .constant(""), currency: .constant([""]), rate: .constant(""))
}
