//
//  TravelView.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import DesignSystem
import Domain
import ComposableArchitecture

public struct TravelView: View {
    @Bindable var store: StoreOf<TravelListFeature>

    public init(store: StoreOf<TravelListFeature>) {
        self.store = store
    }

    public var body: some View {
        GestureNavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    TravelListHeaderView()

                    TabBarView(selectedTab: $store.selectedTab.sending(\.tabChanged))

                    ScrollView {
                        LazyVStack(spacing: 18) {
                            ForEach(store.travels, id: \.id) { travel in
                                TravelCardView(travel: travel)
                                    .onAppear {
                                        store.send(.fetchNextPageIfNeeded(currentItemID: travel.id))
                                    }
                                    .onTapGesture {
                                        //디테일로 이동
                                    }
                            }
                            if store.isLoadingNextPage {
                                ProgressView().padding(.vertical, 20)
                            }
                        }
                        .padding(16)
                    }
                }
                .background(Color.primary50)

                Button {
                    store.send(.createButtonTapped)
                } label: {
                    FloatingPlusButton()
                }
                .padding(.trailing, 20)
                .padding(.bottom, 54)
            }
        }
    }
}
