//
//  TabBarView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/20/25.
//

import SwiftUI
import DesignSystem

enum TravelTab: String, CaseIterable {
    case ongoing = "진행중"
    case completed = "완료됨"
}

struct TabBarView: View {
    @Binding var selectedTab: TravelTab

    var body: some View {
        HStack {
            ForEach(TravelTab.allCases, id: \.self) { tab in
                VStack {
                    Text(tab.rawValue)
                        .font(.app(.title3, weight: .medium))
                        .foregroundStyle(Color.appBlack)
                        .padding(.top, 10)
                        .padding(.bottom, 8)

                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(selectedTab == tab ? Color.primary500 : Color.clear)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTab = tab
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedTab: TravelTab = .ongoing
    TabBarView(selectedTab: $selectedTab)
}
