//
//  SettlementDemoApp.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import SettlementFeature
import ComposableArchitecture

@main
struct SettlementDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SettlementCoordinatorView(store: Store(initialState: SettlementCoordinator.State(travelId: "travel_01"), reducer: {
                    SettlementCoordinator()
                }))
            }
        }
    }
}
