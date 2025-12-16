//
//  TravelLocalDataSource.swift
//  Data
//
//  Created by 김민희 on 12/15/25.
//

import Foundation
import SwiftData
import Domain

public protocol TravelLocalDataSourceProtocol: Actor {
    func load(status: TravelStatus) async throws -> [Travel]?
    func save(travels: [Travel], status: TravelStatus) async throws
    func clear(status: TravelStatus) async throws
}

public actor TravelLocalDataSource: TravelLocalDataSourceProtocol {
    private let container: ModelContainer

    public init(container: ModelContainer? = nil) {
        if let container {
            self.container = container
        } else {
            let schema = Schema([
                TravelCacheEntity.self,
                TravelCacheItemEntity.self,
                TravelCacheMemberEntity.self
            ])
            do {
                self.container = try ModelContainer(
                    for: schema,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: false)
                )
            } catch {
                fatalError("Failed to create Travel cache container: \(error)")
            }
        }
    }

    public func load(status: TravelStatus) async throws -> [Travel]? {
        let context = ModelContext(container)
        guard let cache = try fetchCache(for: status, in: context) else {
            return nil
        }

        // 캐시 시간 만료되면 삭제
        if cache.isExpired {
            context.delete(cache)
            try context.save()
            return nil
        }
        // api로 받은 리스트랑 순서 같도록 정렬
        let sorted = cache.travels.sorted { $0.orderIndex < $1.orderIndex }
        return sorted.map { $0.toDomain() }
    }

    public func save(travels: [Travel], status: TravelStatus) async throws {
        let context = ModelContext(container)
        if let existing = try fetchCache(for: status, in: context) {
            context.delete(existing)
        }

        let cache = TravelCacheEntity(status: status, cachedAt: Date())
        // 순서 유지하기 위해 index 저장
        cache.travels = travels.enumerated().map { index, travel in
            travel.toCacheModel(orderIndex: index)
        }

        context.insert(cache)
        try context.save()
    }

    public func clear(status: TravelStatus) async throws {
        let context = ModelContext(container)
        guard let cache = try fetchCache(for: status, in: context) else { return }
        context.delete(cache)
        try context.save()
    }
}

private extension TravelLocalDataSource {
    func fetchCache(
        for status: TravelStatus,
        in context: ModelContext
    ) throws -> TravelCacheEntity? {
        var descriptor = FetchDescriptor<TravelCacheEntity>()
        // TravelCacheEntity 호출 시 travels도 같이 호출
        descriptor.relationshipKeyPathsForPrefetching = [
            \TravelCacheEntity.travels
        ]
        let caches = try context.fetch(descriptor)
        return caches.first { $0.statusRawValue == status.rawValue }
    }
}
