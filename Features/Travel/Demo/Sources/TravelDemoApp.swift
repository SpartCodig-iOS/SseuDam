//
//  TravelDemoApp.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import TravelFeature
import ComposableArchitecture

@main
struct TravelDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                TravelView(
                    store: Store(
                        initialState: TravelListFeature.State(),
                        reducer: {
                            TravelListFeature()
                        }
                    )
                )
            }
        }
    }
}
