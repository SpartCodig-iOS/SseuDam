//
//  TravelEmptyView.swift
//  TravelFeature
//
//  Created by 김민희 on 12/2/25.
//

import SwiftUI
import DesignSystem

struct TravelEmptyView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(assetName: "EmptyTravelList")
                .resizable()
                .scaledToFit()
                .frame(height: 160)

            Text("여행을 추가해보세요!")
                .font(.app(.title3, weight: .medium))
                .foregroundStyle(Color.appBlack)

            Spacer()
        }
        .padding(.top, 161)
    }
}
