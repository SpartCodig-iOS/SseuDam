//
//  ExpenseDemoApp.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import ExpenseFeature
import ComposableArchitecture

@main
struct ExpenseDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ExpenseView(store: Store(initialState: ExpenseFeature.State(), reducer: {
                    ExpenseFeature()
                }))
            }
        }
    }
}
