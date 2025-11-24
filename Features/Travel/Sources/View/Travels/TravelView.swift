//
//  TravelView.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import DesignSystem

public struct TravelView: View {
    @State private var selectedTab: TravelTab = .ongoing
    @State private var title: String = ""
    @State private var currency: [String] = [""]
    @State private var rate: String = ""
    public init() {}

    public var body: some View {
        GestureNavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    TravelListHeaderView()

                    TabBarView(selectedTab: $selectedTab)

                    ScrollView {
                        VStack(spacing: 18) {
                            TravelCardView()
                            TravelCardView()
                            TravelCardView()
                            TravelCardView()
                            TravelCardView()
                            TravelCardView()
                            TravelCardView()
                            TravelCardView()
                        }
                        .padding(16)
                    }
                    .scrollIndicators(.hidden)
                }
                .background(Color.primary50)

                NavigationLink {
                    CreateTravelView(title: $title, currency: $currency, rate: $rate)
                } label: {
                    FloatingPlusButton()
                }
                .padding(.trailing, 20)
                .padding(.bottom, 54)
            }
        }
    }
}

#Preview {
    TravelView()
}
