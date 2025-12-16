//
//  TravelRepositoryProtocol.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

public protocol TravelRepositoryProtocol {
    func fetchTravels(input: FetchTravelsInput) async throws -> [Travel]
    func createTravel(input: CreateTravelInput) async throws -> Travel
    func updateTravel(id: String, input: UpdateTravelInput) async throws -> Travel
    func deleteTravel(id: String) async throws
    func fetchTravelDetail(id: String) async throws -> Travel
    func loadCachedTravels(status: TravelStatus) async throws -> [Travel]?
}
