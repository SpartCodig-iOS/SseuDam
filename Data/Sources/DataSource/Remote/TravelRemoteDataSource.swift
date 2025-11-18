//
//  TravelRemoteDataSource.swift
//  Data
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Domain
import Moya
import NetworkService

public protocol TravelRemoteDataSourceProtocol {
    func fetchTravels(limit: Int, page: Int) async throws -> [TravelResponseDTO]
    func createTravel(body: CreateTravelRequestDTO) async throws -> TravelResponseDTO
    func updateTravel(id: String, body: UpdateTravelRequestDTO) async throws -> TravelResponseDTO
    func deleteTravel(id: String) async throws -> DeleteTravelResponseDTO
}

final class TravelRemoteDataSource: TravelRemoteDataSourceProtocol {

    private let provider: MoyaProvider<TravelAPI>

    init(provider: MoyaProvider<TravelAPI> = MoyaProvider<TravelAPI>()) {
        self.provider = provider
    }

    func fetchTravels(limit: Int, page: Int) async throws -> [TravelResponseDTO] {
        try await provider.request(.fetchTravels(limit: limit, page: page))
    }

    func createTravel(body: CreateTravelRequestDTO) async throws -> TravelResponseDTO {
        try await provider.request(.createTravel(body: body))
    }

    func updateTravel(id: String, body: UpdateTravelRequestDTO) async throws -> TravelResponseDTO {
        try await provider.request(.updateTravel(id: id, body: body))
    }

    func deleteTravel(id: String) async throws -> DeleteTravelResponseDTO {
        try await provider.request(.deleteTravel(id: id))
    }
}

