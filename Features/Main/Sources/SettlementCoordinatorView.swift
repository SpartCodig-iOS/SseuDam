//
//  SettlementCoordinatorView.swift
//  MainFeature
//
//  Created by 홍석현 on 11/30/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators
import SettlementFeature
import ExpenseFeature
import TravelFeature

public struct SettlementCoordinatorView: View {
    let store: StoreOf<SettlementCoordinator>

    public init(store: StoreOf<SettlementCoordinator>) {
        self.store = store
    }

    public var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case .expense(let store):
                ExpenseView(store: store)
            case .settlement(let store):
                SettlementView(store: store)
            case .travelDetail(let store):
                CreateTravelView(store: store)
            }
        }
    }
}
