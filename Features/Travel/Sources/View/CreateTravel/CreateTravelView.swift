//
//  CreateTravelView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/21/25.
//

import SwiftUI

struct CreateTravelView: View {
    @Binding var title: String
    @Binding var currency: [String]
    @Binding var rate: String
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    TravelInfoView(title: $title)
                    ExchangeRateView(currency: $currency, rate: $rate)
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

#Preview {
    CreateTravelView(title: .constant(""), currency: .constant([""]), rate: .constant(""))
}
