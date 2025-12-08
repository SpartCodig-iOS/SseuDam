//
//  SettlementCoordinatorView.swift
//  MainFeature
//
//  Created by 홍석현 on 11/30/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators
import SaveExpenseFeature

public struct SettlementCoordinatorView: View {
    let store: StoreOf<SettlementCoordinator>

    public init(store: StoreOf<SettlementCoordinator>) {
        self.store = store
    }

    public var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case .saveExpense(let store):
                SaveExpenseView(store: store)
            case .settlement(let store):
                SettlementView(store: store)
            }
        }
    }
}
