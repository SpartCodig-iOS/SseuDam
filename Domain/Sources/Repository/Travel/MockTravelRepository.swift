//
//  MockTravelRepository.swift
//  Domain
//
//  Created by 김민희 on 11/26/25.
//


import Foundation

public final class MockTravelRepository: TravelRepositoryProtocol {
    public init() {}

    public func fetchTravels(input: FetchTravelsInput) async throws -> [Travel] {
        return []
    }

    public func createTravel(input: CreateTravelInput) async throws -> Travel {
        return Travel(
            id: "",
            title: input.title,
            startDate: input.startDate,
            endDate: input.endDate,
            countryCode: input.countryCode,
            baseCurrency: input.baseCurrency,
            baseExchangeRate: input.baseExchangeRate,
            inviteCode: "",
            status: .active,
            role: "",
            createdAt: Date(),
            ownerName: "",
            members: []
        )
    }

    public func updateTravel(id: String, input: UpdateTravelInput) async throws -> Travel {
        throw NSError(domain: "MockTravelRepository", code: -1)
    }

    public func deleteTravel(id: String) async throws { }
}
