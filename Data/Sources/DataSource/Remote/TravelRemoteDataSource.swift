//
//  TravelRemoteDataSource.swift
//  Data
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Domain

protocol TravelRemoteDataSourceProtocol {
    func fetchTravels(limit: Int, page: Int) async throws -> [TravelResponseDTO]
    func createTravel(_ body: CreateTravelRequestDTO) async throws -> TravelResponseDTO
    func updateTravel(id: String, body: UpdateTravelRequestDTO) async throws -> TravelResponseDTO
    func deleteTravel(id: String) async throws -> DeleteTravelResponseDTO
}

final class TravelRemoteDataSource: TravelRemoteDataSourceProtocol {
    
    private let api: APIClient
    
    init(api: APIClient) {
        self.api = api
    }
    
    func fetchTravels(limit: Int, page: Int) async throws -> [TravelResponseDTO] {
        try await api.request(
            method: .GET,
            path: "/api/v1/travels",
            query: [
                "limit": "\(limit)",
                "page": "\(page)"
            ]
        )
    }
    
    func createTravel(_ body: CreateTravelRequestDTO) async throws -> TravelResponseDTO {
        try await api.request(
            method: .POST,
            path: "/api/v1/travels",
            body: body
        )
    }
    
    func updateTravel(id: String, body: UpdateTravelRequestDTO) async throws -> TravelResponseDTO {
        try await api.request(
            method: .PATCH,
            path: "/api/v1/travels/\(id)",
            body: body
        )
    }
    
    func deleteTravel(id: String) async throws -> DeleteTravelResponseDTO {
        try await api.request(
            method: .DELETE,
            path: "/api/v1/travels/\(id)"
        )
    }
}
