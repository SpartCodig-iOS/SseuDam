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
    private let store = Store(initialState: TravelListFeature.State()) {
        TravelListFeature()
    } withDependencies: {
        $0.fetchTravelsUseCase = makeFetchTravelsUseCase()
        $0.createTravelUseCase = makeCreateTravelUseCase()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                TravelView(store: store)
            }
        }
    }
}

private extension TravelDemoApp {
    static func makeFetchTravelsUseCase() -> FetchTravelsUseCase {
        FetchTravelsUseCase(
            repository: TravelRepository(
                remote: TravelRemoteDataSource()
            )
        )
    }

    static func makeCreateTravelUseCase() -> CreateTravelUseCase {
        CreateTravelUseCase(
            repository: TravelRepository(
                remote: TravelRemoteDataSource()
            )
        )
    }
}
