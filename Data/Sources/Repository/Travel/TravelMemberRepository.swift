//
//  TravelMemberRepository.swift
//  Data
//
//  Created by 김민희 on 12/1/25.
//

import Foundation
import Domain

public final class TravelMemberRepository: TravelMemberRepositoryProtocol {

    private let remote: TravelMemberRemoteDataSourceProtocol

    public init(remote: TravelMemberRemoteDataSourceProtocol) {
        self.remote = remote
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
