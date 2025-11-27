//
//  CountrySelectSheetView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/24/25.
//

import SwiftUI
import DesignSystem

struct CountrySelectSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCountry: String?
    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("국가 선택")
                    .font(.app(.title3, weight: .semibold))
                    .padding(.top, 14)
                    .padding(.bottom, 30)

                HStack {
                    TextField("찾으시는 국가를 검색해보세요", text: $searchText)
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

            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    countryRow("한국")
                    countryRow("미국")
                    countryRow("아르헨티나")
                    countryRow("일본")
                    countryRow("영국")
                    countryRow("호주")
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.primary50)
    }

    private func countryRow(_ country: String) -> some View {
        Text(country)
            .font(.app(.title3, weight: .medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .onTapGesture {
                selectedCountry = country
                dismiss()
            }
    }
}
