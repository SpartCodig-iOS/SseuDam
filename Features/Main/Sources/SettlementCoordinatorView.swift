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
            SwitchStore(screen) { state in
                switch state {
                case .settlement:
                    CaseLet(
                        /SettlementScreen.State.settlement,
                        action: SettlementScreen.Action.settlement,
                        then: SettlementView.init(store:)
                    )

                case .expense:
                    CaseLet(
                        /SettlementScreen.State.expense,
                        action: SettlementScreen.Action.expense,
                        then: ExpenseView.init(store:)
                    )

                case .travelDetail:
                    CaseLet(
                        /SettlementScreen.State.travelDetail,
                        action: SettlementScreen.Action.travelDetail,
                        then: CreateTravelView.init(store:)
                    )
                }
            }
        }
    }
}
