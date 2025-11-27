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
                        title: Binding(
                            get: { store.title },
                            set: { store.send(.titleChanged($0)) }
                        ),
                        selectedCountry: Binding(
                            get: { store.selectedCountry },
                            set: { store.send(.countryChanged($0)) }
                        ),
                        startDate: Binding(
                            get: { store.startDate },
                            set: { store.send(.startDateChanged($0)) }
                        ),
                        endDate: Binding(
                            get: { store.endDate },
                            set: { store.send(.endDateChanged($0)) }
                        )
                    )

                    if store.selectedCountry != "한국",
                       store.selectedCountry != nil {
                        ExchangeRateView(
                            currency: Binding(
                                get: { store.currency },
                                set: { store.send(.currencyChanged($0)) }
                            ),
                            selectedCurrency: Binding(
                                get: { store.selectedCurrency },
                                set: { store.send(.currencySelected($0 ?? "")) }
                            ),
                            rate: Binding(
                                get: { store.rate },
                                set: { store.send(.rateChanged($0)) }
                            ),
                            onCurrencyFieldTapped: {
                                store.send(.currencyFieldTapped)
                            }
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
