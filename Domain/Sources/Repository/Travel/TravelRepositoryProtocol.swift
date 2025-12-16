//
//  TravelRepositoryProtocol.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Dependencies

public protocol TravelRepositoryProtocol {
    func fetchTravels(input: FetchTravelsInput) async throws -> [Travel]
    func createTravel(input: CreateTravelInput) async throws -> Travel
    func updateTravel(id: String, input: UpdateTravelInput) async throws -> Travel
    func deleteTravel(id: String) async throws
    func fetchTravelDetail(id: String) async throws -> Travel
    func loadCachedTravels(status: TravelStatus) async throws -> [Travel]?
}

// MARK: - Dependency
private enum TravelRepositoryDepensencyKey: DependencyKey {
    static let liveValue: TravelRepositoryProtocol = {
        fatalError("TravelRepository liveValue not implemented")
    }()

    static let testValue: TravelRepositoryProtocol = MockTravelRepository()
}

extension DependencyValues {
    public var travelRepository: TravelRepositoryProtocol {
        get { self[TravelRepositoryDepensencyKey.self] }
        set { self[TravelRepositoryDepensencyKey.self] = newValue }
    }
}
