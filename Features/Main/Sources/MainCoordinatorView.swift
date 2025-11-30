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
            SwitchStore(screen) { state in
                switch state {
                case .travelList:
                    CaseLet(
                        /Screen.State.travelList,
                        action: Screen.Action.travelList,
                        then: TravelView.init(store:)
                    )

                case .createTravel:
                    CaseLet(
                        /Screen.State.createTravel,
                        action: Screen.Action.createTravel,
                        then: CreateTravelView.init(store:)
                    )

                case .settlementCoordinator:
                    CaseLet(
                        /Screen.State.settlementCoordinator,
                        action: Screen.Action.settlementCoordinator,
                        then: SettlementCoordinatorView.init(store:)
                    )
                }
            }
        }
    }
}
