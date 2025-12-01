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
    private static let repo = TravelRepository(remote: TravelRemoteDataSource())

    private let store = Store(initialState: TravelListFeature.State()) {
        TravelListFeature()
    } withDependencies: {
        $0.fetchTravelsUseCase = FetchTravelsUseCase(repository: repo)
        $0.createTravelUseCase = CreateTravelUseCase(repository: repo)
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
//                TravelView(store: store)
                TravelSettingView()
            }
        }
    }
}
