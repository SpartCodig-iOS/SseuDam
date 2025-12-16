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

    // 로컬 캐시 파일이 갱신될 때마다 스트림을 통해 최신 Travel 배열을 방출
    public func observeCachedTravels(status: TravelStatus) -> AsyncStream<[Travel]> {
        AsyncStream { continuation in
            let task = Task {
                let baseStream = await local.observe(status: status)
                for await cacheItems in baseStream {
                    guard !Task.isCancelled else { break }
                    let travels = cacheItems.map { $0.toDomain() }
                    continuation.yield(travels)
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

private extension TravelRepository {
    func persistCache(
        travels: [Travel],
        status: TravelStatus,
        appendExisting: Bool
    ) async throws {
        var cacheItems = travels.map { $0.toCacheItem() }

        if appendExisting,
           let existing = try? await local.load(status: status)?.travels {
            cacheItems = existing + cacheItems
        }

        let deduped = deduplicate(items: cacheItems)
        let cache = TravelCacheDTO(
            statusRawValue: status.rawValue,
            cachedAt: Date(),
            travels: deduped
        )
        try await local.save(cache)
    }

    // 한 번 캐시된 여행은 다시 저장하지 않도록 ID 기반으로 중복을 제거한다.
    func deduplicate(items: [TravelCacheItemDTO]) -> [TravelCacheItemDTO] {
        var seen = Set<String>()
        return items.filter { item in
            guard !seen.contains(item.id) else { return false }
            seen.insert(item.id)
            return true
        }
    }
}
