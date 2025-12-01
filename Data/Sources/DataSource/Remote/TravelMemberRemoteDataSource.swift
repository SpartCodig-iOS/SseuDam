//
//  TravelMemberRemoteDataSource.swift
//  Data
//
//  Created by 김민희 on 12/1/25.
//

import Foundation
import Moya
import NetworkService

public protocol TravelMemberRemoteDataSourceProtocol {
    func deleteMember(travelId: String, memberId: String) async throws
    func joinTravel(_ body: JoinTravelRequestDTO) async throws -> TravelResponseDTO
    func delegateOwner(travelId: String, body: DelegateOwnerRequestDTO) async throws -> TravelResponseDTO
    func leaveTravel(travelId: String) async throws
}

public final class TravelMemberRemoteDataSource: TravelMemberRemoteDataSourceProtocol {
    private let provider: MoyaProvider<TravelAPI>

    public init(provider: MoyaProvider<TravelAPI> = MoyaProvider<TravelAPI>.default) {
        self.provider = provider
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


