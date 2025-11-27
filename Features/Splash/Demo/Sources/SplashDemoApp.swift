//
//  SplashDemoApp.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import SplashFeature

@main
struct SplashDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
              SplashView(store: .init(initialState: SplashFeature.State(), reducer: {
                SplashFeature()
              }))
            }
        }
    }
}
