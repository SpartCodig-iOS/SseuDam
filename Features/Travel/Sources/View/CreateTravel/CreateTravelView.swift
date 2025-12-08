//
//  CreateTravelView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/21/25.
//

import SwiftUI
import ComposableArchitecture

public struct CreateTravelView: View {
    @Bindable var store: StoreOf<TravelCreateFeature>
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<TravelCreateFeature>) {
        self.store = store
    }
    
    public var body: some View {
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
                    // MARK: - 여행 기본 정보
                    TravelInfoView(store: store)

                    // MARK: - 환율 정보 (한국 제외)
                    if let code = store.selectedCountryCode,
                       code != "KR" {

                        ExchangeRateView(
                            currency: Binding(
                                get: { store.currency },
                                set: { _ in }
                            ),
                            selectedCurrency: Binding(
                                get: { store.selectedCurrency },
                                set: { newValue in
                                    if let v = newValue {
                                        store.send(.currencySelected(v))
                                    }
                                }
                            ),
                            rate: Binding(
                                get: { store.rate },
                                set: { store.send(.rateChanged($0)) }
                            ),
                            onCurrencyFieldTapped: {}
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollDismissesKeyboard(.immediately)
            .scrollIndicators(.hidden)

            // MARK: 저장
            SaveButton(isEnabled: store.isSaveEnabled && !store.isSubmitting) {
                store.send(.saveButtonTapped)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .background(Color.primary50)
        .navigationBarBackButtonHidden(true)
    }
}
