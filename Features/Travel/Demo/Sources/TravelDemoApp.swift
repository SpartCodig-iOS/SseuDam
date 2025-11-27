//
//  TravelDemoApp.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//

import SwiftUI
import ComposableArchitecture
import Data
import Domain
import NetworkService
import TravelFeature

@main
struct TravelDemoApp: App {

    private static let mockRepo = MockTravelRepository()

    private let store = Store(initialState: TravelListFeature.State()) {
        TravelListFeature()
    } withDependencies: {
        $0.fetchTravelsUseCase = FetchTravelsUseCase(repository: mockRepo)
        $0.createTravelUseCase = CreateTravelUseCase(repository: mockRepo)
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                TravelView(store: store)
            }
        }
    }
}
