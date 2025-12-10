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
    func joinTravel(_ body: JoinTravelRequestDTO) async throws -> TravelDTO
    func delegateOwner(travelId: String, body: DelegateOwnerRequestDTO) async throws -> TravelDTO
    func leaveTravel(travelId: String) async throws
    func fetchMember(travelId: String) async throws -> FetchMemberResponseDTO
}

public final class TravelMemberRemoteDataSource: TravelMemberRemoteDataSourceProtocol {
    private let provider: MoyaProvider<TravelAPI>

    public init(provider: MoyaProvider<TravelAPI> = MoyaProvider<TravelAPI>.default) {
        self.provider = provider
    }

    public func deleteMember(travelId: String, memberId: String) async throws {
        let _: BaseResponse<EmptyDTO> = try await provider.request(.deleteMember(travelId: travelId, memberId: memberId))
    }

    public func joinTravel(_ body: JoinTravelRequestDTO) async throws -> TravelDTO {
        let response: BaseResponse<TravelDTO> = try await provider.request(.joinTravel(body: body))

        guard let data = response.data else {
            throw NetworkError.noData
        }

        return data
    }

    public func delegateOwner(travelId: String, body: DelegateOwnerRequestDTO) async throws -> TravelDTO {
        let response: BaseResponse<TravelDTO> = try await provider.request(.delegateOwner(travelId: travelId, body: body))

        guard let data = response.data else {
            throw NetworkError.noData
        }

        return data
    }

    public func leaveTravel(travelId: String) async throws {
        let _: BaseResponse<EmptyDTO> = try await provider.request(.leaveTravel(travelId: travelId))
    }

    public func fetchMember(travelId: String) async throws -> FetchMemberResponseDTO {
        let response: BaseResponse<FetchMemberResponseDTO> = try await provider.request(.fetchMember(travelId: travelId))

        guard let data = response.data else {
            throw NetworkError.noData
        }

        return data
    }
}
