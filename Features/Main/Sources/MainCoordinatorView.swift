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
import ExpenseFeature

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
            case .travelList(let store):
                TravelView(store: store)
            case .createTravel(let store):
                CreateTravelView(store: store)
            }
        }
    }
}
