//
//  MainDemoApp.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import MainFeature
import ComposableArchitecture

@main
struct MainDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainCoordinatorView(store: Store(initialState: MainCoordinator.State(), reducer: {
                    MainCoordinator()
                }))
            }
        }
    }
}
