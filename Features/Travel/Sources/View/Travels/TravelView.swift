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
        ZStack {
            Color.primary50.ignoresSafeArea()
            
            if store.isLoading {
                DashboardSkeletonView()
            } else {
                VStack {
                    TravelListHeaderView {
                        store.send(.profileButtonTapped)
                    }
                    
                    TabBarView(selectedTab: $store.selectedTab.sending(\.travelTabSelected))
                    
                    if store.travels.isEmpty {
                        TravelEmptyView()
                    } else {
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
                }
            }
        }
        .task {
          store.send(.onAppear)
        }
//        .onAppear {
//            store.send(.onAppear)
//        }
        .overlay(alignment: .bottomTrailing) {
            if !store.isLoading {
                ZStack(alignment: .bottomTrailing) {
                    if store.isMenuOpen {
                        TravelCreateMenuView(
                            inviteTapped: { store.send(.selectInviteCode) },
                            createTapped: { store.send(.selectCreateTravel) }
                        )
                        .padding(.trailing, 20)
                        .padding(.bottom, 116)
                    }

                    FloatingMenuButton(isOpen: store.isMenuOpen) {
                        store.send(.floatingButtonTapped)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 54)
                }
            }
        }
        .overlay {
            if store.isPresentInvitationView {
                InviteCodeModalView(
                    code: store.inviteCode,
                    onCodeChange: { store.send(.inviteCodeChanged($0)) },
                    onConfirm: { store.send(.inviteConfirm) },
                    onCancel: { store.send(.inviteModalDismiss) }
                )
            }
        }
    }
}
