//
//  TravelRemoteDataSource.swift
//  Data
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Moya
import NetworkService

public protocol TravelRemoteDataSourceProtocol {
    func fetchTravels(body: FetchTravelsRequestDTO) async throws -> [TravelResponseDTO]
    func createTravel(body: CreateTravelRequestDTO) async throws -> TravelResponseDTO
    func updateTravel(id: String, body: UpdateTravelRequestDTO) async throws -> TravelResponseDTO
    func deleteTravel(id: String) async throws
    func fetchTravelDetail(id: String) async throws -> TravelResponseDTO
    func deleteMember(travelId: String, memberId: String) async throws
    func joinTravel(_ body: JoinTravelRequestDTO) async throws -> TravelResponseDTO
    func delegateOwner(travelId: String, body: DelegateOwnerRequestDTO) async throws -> TravelResponseDTO
    func leaveTravel(travelId: String) async throws
}

public final class TravelRemoteDataSource: TravelRemoteDataSourceProtocol {
    private let provider: MoyaProvider<TravelAPI> 

    public init(provider: MoyaProvider<TravelAPI> = MoyaProvider<TravelAPI>.default) {
        self.provider = provider
    }

    public func fetchTravels(
        body: FetchTravelsRequestDTO
    ) async throws -> [TravelResponseDTO] {
        let response: BaseResponse<[TravelResponseDTO]> =
        try await provider.request(.fetchTravels(body: body))

        return response.data ?? []
    }

    public func createTravel(
        body: CreateTravelRequestDTO
    ) async throws -> TravelResponseDTO {

        let response: BaseResponse<TravelResponseDTO> =
        try await provider.request(.createTravel(body: body))

        guard let data = response.data else {
            throw NetworkError.noData
        }

        return data
    }

    public func updateTravel(
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

    public func deleteTravel(id: String) async throws {
        let _: BaseResponse<EmptyDTO> = try await provider.request(.deleteTravel(id: id))
    }
    
    public func fetchTravelDetail(id: String) async throws -> TravelResponseDTO {
        let response: BaseResponse<TravelResponseDTO> =
        try await provider.request(.fetchTravelDetail(id: id))
        
        guard let data = response.data else {
            throw NetworkError.noData
        }
        
        return data
    }

    public func deleteMember(travelId: String, memberId: String) async throws {
        let _: BaseResponse<EmptyDTO> = try await provider.request(.deleteMember(travelId: travelId, memberId: memberId))
    }

    public func joinTravel(_ body: JoinTravelRequestDTO) async throws -> TravelResponseDTO {
        try await provider.request(.joinTravel(body: body))
    }

    public func delegateOwner(travelId: String, body: DelegateOwnerRequestDTO) async throws -> TravelResponseDTO {
        try await provider.request(.delegateOwner(travelId: travelId, body: body))
    }

    public func leaveTravel(travelId: String) async throws {
        let _: BaseResponse<EmptyDTO> = try await provider.request(.leaveTravel(travelId: travelId))
    }
}

