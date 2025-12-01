//
//  TravelRepository.swift
//  Data
//
//  Created by 김민희 on 11/18/25.
//

import Foundation
import Domain

public final class TravelRepository: TravelRepositoryProtocol {

    private let remote: TravelRemoteDataSourceProtocol

    public init(remote: TravelRemoteDataSourceProtocol) {
        self.remote = remote
    }

    public func fetchTravels(
        input: FetchTravelsInput
    ) async throws -> [Travel] {
        let requestDTO = input.toDTO()
        let dtoList = try await remote.fetchTravels(body: requestDTO)
        return dtoList.map { $0.toDomain() }
    }

    public func createTravel(
        input: CreateTravelInput
    ) async throws -> Travel {
        let requestDTO = input.toDTO()
        let responseDTO = try await remote.createTravel(body: requestDTO)
        return responseDTO.toDomain()
    }

    public func updateTravel(
        id: String,
        input: UpdateTravelInput
    ) async throws -> Travel {
        let requestDTO = input.toDTO()
        let responseDTO = try await remote.updateTravel(id: id, body: requestDTO)
        return responseDTO.toDomain()
    }

    public func deleteTravel(
        id: String
    ) async throws {
        try await remote.deleteTravel(id: id)
    }
    
    public func fetchTravelDetail(
        id: String
    ) async throws -> Travel {
        let responseDTO = try await remote.fetchTravelDetail(id: id)
        return responseDTO.toDomain()
    }

    public func deleteMember(
        travelId: String,
        memberId: String
    ) async throws {
        try await remote.deleteMember(travelId: travelId, memberId: memberId)
    }

    public func joinTravel(
        inviteCode: String
    ) async throws -> Travel {
        let dto = JoinTravelRequestDTO(inviteCode: inviteCode)
        let response = try await remote.joinTravel(dto)
        return response.toDomain()
    }

    public func delegateOwner(
        travelId: String,
        newOwnerId: String
    ) async throws -> Travel {
        let dto = DelegateOwnerRequestDTO(newOwnerId: newOwnerId)
        let response = try await remote.delegateOwner(travelId: travelId, body: dto)
        return response.toDomain()
    }

    public func leaveTravel(
        travelId: String
    ) async throws {
        try await remote.leaveTravel(travelId: travelId)
    }
}
