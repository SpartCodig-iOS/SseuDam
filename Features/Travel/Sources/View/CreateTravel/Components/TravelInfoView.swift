//
//  TravelInfoView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/21/25.
//

import SwiftUI
import DesignSystem

struct TravelInfoView: View {
    @Binding var title: String
    @Binding var selectedCountry: String?
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @State private var isCountrySheetPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("여행 정보")
                .font(.app(.title3, weight: .semibold))
                .foregroundStyle(Color.appBlack)

            VStack(spacing: 16) {
                InputTextField(
                    text: $title,
                    title: "여행 이름",
                    essential: true,
                    placeholder: "ex) 제주도 여행",
                    isEnabled: true
                )

                DateRangeView(
                    startDate: $startDate,
                    endDate: $endDate,
                    title: "여행 기간",
                    essential: true
                )

                SelectField(
                    title: "국가", 
                    essential: true,
                    placeholder: "국가를 선택해주세요",
                    value: selectedCountry,
                    onTap: {
                        isCountrySheetPresented = true
                    }
                )
            }
        }
        .sheet(isPresented: $isCountrySheetPresented) {
            CountrySelectSheetView(selectedCountry: $selectedCountry)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    TravelInfoView(
        title: .constant("여행 정보"),
        selectedCountry: .constant(nil),
        startDate: .constant(nil),
        endDate: .constant(nil)
    )
}
