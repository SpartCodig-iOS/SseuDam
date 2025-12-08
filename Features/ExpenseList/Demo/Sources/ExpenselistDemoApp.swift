//
//  ExpenseListDemoApp.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import ExpenseListFeature

@main
struct ExpenseListDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ExpenseListView()
            }
        }
    }
}