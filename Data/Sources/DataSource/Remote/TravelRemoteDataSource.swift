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
    func fetchTravels(body: FetchTravelsRequestDTO) async throws -> [TravelResponseDTO]
    func createTravel(body: CreateTravelRequestDTO) async throws -> TravelResponseDTO
    func updateTravel(id: String, body: UpdateTravelRequestDTO) async throws -> TravelResponseDTO
    func deleteTravel(id: String) async throws
    func fetchTravelDetail(id: String) async throws -> TravelResponseDTO
}

final class TravelRemoteDataSource: TravelRemoteDataSourceProtocol {

    private let provider: MoyaProvider<TravelAPI>

    init(provider: MoyaProvider<TravelAPI> = MoyaProvider<TravelAPI>()) {
        self.provider = provider
    }

    func fetchTravels(
        body: FetchTravelsRequestDTO
    ) async throws -> [TravelResponseDTO] {
        let response: BaseResponse<[TravelResponseDTO]> =
        try await provider.request(.fetchTravels(body: body))

        return response.data ?? []
    }

    func createTravel(
        body: CreateTravelRequestDTO
    ) async throws -> TravelResponseDTO {
        let response: BaseResponse<TravelResponseDTO> =
        try await provider.request(.createTravel(body: body))

        guard let data = response.data else {
            throw NetworkError.noData
        }

        return data
    }

    func updateTravel(
        id: String,
        body: UpdateTravelRequestDTO
    ) async throws -> TravelResponseDTO {
        let response: BaseResponse<TravelResponseDTO> =
        try await provider.request(.updateTravel(id: id, body: body))

        guard let data = response.data else {
            throw NetworkError.noData
        }

        return data
    }

    func deleteTravel(id: String) async throws {
        let _: BaseResponse<EmptyDTO> =
        try await provider.request(.deleteTravel(id: id))
    }
    
    func fetchTravelDetail(id: String) async throws -> TravelResponseDTO {
        let response: BaseResponse<TravelResponseDTO> =
        try await provider.request(.fetchTravelDetail(id: id))
        
        guard let data = response.data else {
            throw NetworkError.noData
        }
        
        return data
    }
}

