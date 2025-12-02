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
    private static let mockTravelRepo = MockTravelRepository()
    private static let mockTravelMemberRepo = MockTravelMemberRepository()
    private static let mockCountriesRepo = MockCountriesRepository()
    private static let mockExchangeRateRepo = MockExchangeRateRepository()

    private static let repo = TravelRepository(remote: TravelRemoteDataSource())

    private let store = Store(initialState: TravelListFeature.State()) {
        TravelListFeature()
    } withDependencies: {
        $0.fetchTravelsUseCase = FetchTravelsUseCase(repository: repo)
        $0.createTravelUseCase = CreateTravelUseCase(repository: repo)
    }

    private let settingStore = Store(initialState: TravelSettingFeature.State(
        travel: Travel(
        id: "MOCK-1",
        title: "여행 1",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
        countryCode: ["KR", "JP", "US"].randomElement()!,
        baseCurrency: "KRW",
        baseExchangeRate: 1.0,
        inviteCode: "INV-0001",
        status: .active,
        role: "owner",
        createdAt: Date(),
        ownerName: "김민희",
        members: [
            TravelMember(id: "MOCKmember-0", name: "김민희", role: "owner"),
            TravelMember(id: "MOCKmember-1", name: "친구1", role: "member"),
            TravelMember(id: "MOCKmember-2", name: "친구2", role: "member"),
            TravelMember(id: "MOCKmember-3", name: "친구3", role: "member")
        ]
    ))) {
        TravelSettingFeature()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
//                TravelView(store: store)
                TravelSettingView(store: settingStore)
            }
        }
    }
}
