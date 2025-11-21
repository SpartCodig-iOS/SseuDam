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
    public init() {}

    public var body: some View {
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
    }
}

#Preview {
    TravelView()
}
