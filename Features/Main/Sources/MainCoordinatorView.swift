//
//  MainCoordinatorView.swift
//  MainFeature
//
//  Created by 홍석현 on 11/30/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators
import TravelFeature
import SettlementFeature
import ProfileFeature
import MemberFeature

public struct MainCoordinatorView: View {
    let store: StoreOf<MainCoordinator>
    
    public init(store: StoreOf<MainCoordinator>) {
        self.store = store
    }
    
    public var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case .settlementCoordinator(let store):
                SettlementCoordinatorView(store: store)
                    .enableSwipeBack()
            case .travelList(let store):
                TravelView(store: store)
                    .enableSwipeBack()
            case .createTravel(let store):
                CreateTravelView(store: store)
            case .travelSetting(let store):
                TravelSettingView(store: store)
                    .enableSwipeBack()
            case .updateTravel(let store):
                UpdateTravelView(store: store)
                    .enableSwipeBack()
            case .profile(let store):
                ProfileCoordinatorView(store: store)
                    .navigationBarBackButtonHidden()
                    .enableSwipeBack()
            case .memberManage(let store):
                MemberView(store: store)
                    .enableSwipeBack()
            }
        }
    }
}
