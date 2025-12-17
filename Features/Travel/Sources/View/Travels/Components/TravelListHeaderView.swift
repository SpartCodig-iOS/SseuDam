//
//  TravelListHeaderView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/20/25.
//

import SwiftUI
import DesignSystem

struct TravelListHeaderView: View {
  var action: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text("내 여행")
                .font(.app(.title1, weight: .semibold))
                .foregroundStyle(Color.appBlack)

            Spacer()

            Image(assetName: "user")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
                .foregroundStyle(Color.appBlack)
                .onTapGesture {
                  action()
                }
        }
        .padding(20)
    }
}

#Preview {
  TravelListHeaderView(action: {})
}
