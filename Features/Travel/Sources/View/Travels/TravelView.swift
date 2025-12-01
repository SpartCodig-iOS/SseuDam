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
        VStack {
            TravelListHeaderView()

            TabBarView(selectedTab: $store.selectedTab.sending(\.travelTabSelected))

            ScrollView {
                LazyVStack(spacing: 18) {
                    ForEach(store.travels, id: \.id) { travel in
                        TravelCardView(travel: travel)
                            .onAppear {
                                store.send(.fetchNextPageIfNeeded(currentItemID: travel.id))
                            }
                            .onTapGesture {
                                store.send(.travelSelected(travelId: travel.id))
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
        .overlay(alignment: .bottomTrailing) {
            FloatingPlusButton {
                store.send(.createButtonTapped)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 54)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
