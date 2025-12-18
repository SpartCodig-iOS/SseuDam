//
//  TravelInfoView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/21/25.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

struct TravelInfoView: View {
    @Bindable var store: StoreOf<TravelCreateFeature>
    @State private var isCountrySheetPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("여행 정보")
                .font(.app(.title2, weight: .semibold))
                .foregroundStyle(Color.appBlack)

            VStack(spacing: 16) {
                InputTextField(
                    text: Binding(
                        get: { store.title },
                        set: { store.send(.titleChanged($0)) }
                    ),
                    title: "여행 이름",
                    essential: true,
                    placeholder: "ex) 제주도 여행",
                    isEnabled: true
                )

                DateRangeView(
                    startDate: Binding(
                        get: { store.startDate },
                        set: { store.send(.startDateChanged($0)) }
                    ),
                    endDate: Binding(
                        get: { store.endDate },
                        set: { store.send(.endDateChanged($0)) }
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
        .sheet(isPresented: $isCountrySheetPresented) {
            CountrySelectSheetView(store: store)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}
