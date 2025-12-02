//
//  BasicCountrySelectSheetView.swift
//  TravelFeature
//
//  Created by 김민희 on 12/1/25.
//

import SwiftUI
import DesignSystem
import Domain
import ComposableArchitecture

struct BasicCountrySelectSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var store: StoreOf<BasicSettingFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("국가 선택")
                    .font(.app(.title3, weight: .semibold))
                    .padding(.top, 14)
                    .padding(.bottom, 30)

                HStack {
                    TextField(
                        "찾으시는 국가를 검색해보세요",
                        text: $store.searchText.sending(\.searchTextChanged)
                    )
                    .font(.app(.body))
                    Image(assetName: "search")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                        .foregroundStyle(Color.gray5)
                }
                .padding(.vertical, 12)
                .padding(.leading, 16)
                .padding(.trailing, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)

            if store.isLoadingCountries {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(store.filteredCountries, id: \.code) { country in
                            countryRow(country)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(Color.primary50)
        .task {
            // sheet 뜰 때 국가 목록 로딩
            store.send(.onAppearCountries)
        }
    }

    private func countryRow(_ country: Country) -> some View {
        Text(country.koreanName)
            .font(.app(.title3, weight: .medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .onTapGesture {
                store.send(.countrySelected(country.koreanName))
                dismiss()
            }
    }
}
