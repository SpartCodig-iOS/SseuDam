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
    private let local: TravelLocalDataSourceProtocol

    public init(
        remote: TravelRemoteDataSourceProtocol,
        local: TravelLocalDataSourceProtocol = TravelLocalDataSource()
    ) {
        self.remote = remote
        self.local = local
    }

    public func fetchTravels(
        input: FetchTravelsInput
    ) async throws -> [Travel] {
        let requestDTO = input.toDTO()
        let dtoList = try await remote.fetchTravels(body: requestDTO).items
        let travels = dtoList.map { $0.toDomain() }
        if let status = input.status {
            let appendExisting = input.page > 1
            try await persistCache(
                travels: travels,
                status: status,
                appendExisting: appendExisting
            )
        }
        return travels
    }

    public func loadCachedTravels(
        status: TravelStatus
    ) async throws -> [Travel]? {
        try await local.load(status: status)
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

}

private extension TravelRepository {
    func persistCache(
        travels: [Travel],
        status: TravelStatus,
        appendExisting: Bool
    ) async throws {
        var cacheItems = travels

        if appendExisting,
           let existing = try await local.load(status: status) {
            cacheItems = existing + cacheItems
        }

        let deduped = deduplicate(items: cacheItems)
        try await local.save(travels: deduped, status: status)
    }

    // 한 번 캐시된 여행은 다시 저장하지 않도록 ID 기반으로 중복을 제거한다.
    func deduplicate(items: [Travel]) -> [Travel] {
        var seen = Set<String>()
        return items.filter { item in
            guard !seen.contains(item.id) else { return false }
            seen.insert(item.id)
            return true
        }
    }
}
