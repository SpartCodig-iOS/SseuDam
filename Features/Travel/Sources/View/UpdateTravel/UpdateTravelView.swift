//
//  UpdateTravelView.swift
//  TravelFeature
//
//  Created by 김민희 on 12/12/25.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct UpdateTravelView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: StoreOf<BasicSettingFeature>
    @State private var isCountrySheetPresented = false

    public init(store: StoreOf<BasicSettingFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 16) {
                    travelInfoSection

                    if let code = store.selectedCountryCode,
                       code != "KR" {
                        ExchangeRateView(
                            currency: Binding(
                                get: { store.currencies },
                                set: { _ in }
                            ),
                            selectedCurrency: Binding(
                                get: { store.selectedCurrency },
                                set: { newValue in
                                    guard let value = newValue else { return }
                                    store.send(.currencySelected(value))
                                }
                            ),
                            rate: $store.exchangeRate
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .scrollDismissesKeyboard(.immediately)
            .scrollIndicators(.hidden)

            SaveButton(isEnabled: store.canSave && !store.isSubmitting) {
                store.send(.saveButtonTapped)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(Color.primary50)
        .navigationBarBackButtonHidden(true)
        .task {
            store.send(.onAppearCountries)
        }
        .sheet(isPresented: $isCountrySheetPresented) {
            BasicCountrySelectSheetView(store: store)
                .presentationDetents([.medium, .large])
        }
        .alert(
            store.errorMessage ?? "",
            isPresented: Binding(
                get: { store.errorMessage != nil },
                set: { _ in store.send(.errorDismissed) }
            )
        ) {
            Button("확인", role: .cancel) { }
        }
    }
}

private extension UpdateTravelView {
    var header: some View {
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

            Text("여행 수정")
                .font(.app(.title1, weight: .semibold))
                .foregroundStyle(Color.appBlack)

            Spacer()
        }
        .padding(20)
    }

    var travelInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("여행 정보")
                .font(.app(.title2, weight: .semibold))
                .foregroundStyle(Color.appBlack)

            VStack(spacing: 16) {
                InputTextField(
                    text: $store.title.sending(\.titleChanged),
                    title: "여행 이름",
                    essential: true,
                    placeholder: "ex) 제주도 여행",
                    isEnabled: true
                )

                DateRangeView(
                    startDate: Binding(
                        get: { store.startDate },
                        set: { newValue in
                            guard let value = newValue else { return }
                            store.send(.startDateChanged(value))
                        }
                    ),
                    endDate: Binding(
                        get: { store.endDate },
                        set: { newValue in
                            guard let value = newValue else { return }
                            store.send(.endDateChanged(value))
                        }
                    ),
                    title: "여행 기간",
                    essential: true
                )

                SelectField(
                    title: "국가",
                    essential: true,
                    placeholder: "국가를 선택해주세요",
                    value: store.selectedCountryName,
                    onTap: {
                        isCountrySheetPresented = true
                    }
                )
            }
        }
    }
}
