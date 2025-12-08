//
//  SaveExpenseDemoApp.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import SaveExpenseFeature
import ComposableArchitecture

@main
struct SaveExpenseDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SaveExpenseView(store: Store(initialState: SaveExpenseFeature.State("travel_id"), reducer: {
                    SaveExpenseFeature()
                }))
            }
        }
    }
}
