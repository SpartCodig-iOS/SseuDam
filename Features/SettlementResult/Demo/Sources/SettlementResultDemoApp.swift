//
//  SettlementResultDemoApp.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import SettlementResultFeature
import ComposableArchitecture

@main
struct SettlementResultDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SettlementResultView(
                    store: Store(
                        initialState: SettlementResultFeature.State(
                            travelId: "travel_id",
                            travel: .init(value: nil),
                            expenses: .init(value: [])
                        ),
                        reducer: {
                            SettlementResultFeature()
                        })
                )
            }
        }
    }
}
