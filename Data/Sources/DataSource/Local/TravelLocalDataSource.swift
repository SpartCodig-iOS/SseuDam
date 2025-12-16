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
    func load(travelId: String) async throws -> Travel?
    func save(travels: [Travel], status: TravelStatus) async throws
    func upsert(travel: Travel) async throws
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
                    configurations: ModelConfiguration(
                        isStoredInMemoryOnly: false
                    )
                )
            } catch {
                fatalError("Failed to create Travel cache container: \(error)")
            }
        }
    }
    
    // 상태별 여행 리스트 조회
    public func load(status: TravelStatus) async throws -> [Travel]? {
        let context = makeContext()
        
        guard let statusCache = try fetchCache(
            for: status,
            in: context
        ) else {
            return nil
        }
        
        if statusCache.isExpired {
            context.delete(statusCache)
            try context.save()
            return nil
        }
        
        return statusCache.travels
            .sorted { $0.orderIndex < $1.orderIndex }
            .map { $0.toDomain() }
    }
    
    // travelId로 여행 조회
    public func load(travelId: String) async throws -> Travel? {
        let context = makeContext()
        
        let caches = try fetchAllCaches(in: context)
        let validCaches = try purgeExpiredCaches(caches, in: context)
        
        for cache in validCaches {
            if let cachedTravel = cache.travels.first(where: { $0.id == travelId }) {
                return cachedTravel.toDomain()
            }
        }
        
        return nil
    }
    
    // 여행 리스트 전체 저장
    public func save(travels: [Travel], status: TravelStatus) async throws {
        let context = makeContext()
        
        if let existing = try fetchCache(for: status, in: context) {
            context.delete(existing)
        }
        
        let statusCache = TravelCacheEntity(
            status: status,
            cachedAt: Date()
        )
        
        statusCache.travels = travels.enumerated().map { index, travel in
            travel.toCacheModel(orderIndex: index)
        }
        
        context.insert(statusCache)
        try context.save()
    }
    
    // 여행 insert or update
    public func upsert(travel: Travel) async throws {
        let context = makeContext()
        let caches = try fetchAllCaches(in: context)
        
        // 기존 여행 제거
        var preservedOrderIndex: Int?
        
        for cache in caches {
            if let index = cache.travels.firstIndex(where: { $0.id == travel.id }) {
                preservedOrderIndex = cache.travels[index].orderIndex
                cache.travels.remove(at: index)
            }
        }
        
        // 대상 상태 캐시 찾기 or 생성
        let destinationCache = caches.first {
            $0.statusRawValue == travel.status.rawValue
        } ?? {
            let newCache = TravelCacheEntity(
                status: travel.status,
                cachedAt: Date()
            )
            context.insert(newCache)
            return newCache
        }()
        
        // orderIndex 유지 또는 append
        let orderIndex = preservedOrderIndex ?? destinationCache.travels.count
        destinationCache.travels.append(
            travel.toCacheModel(orderIndex: orderIndex)
        )
        destinationCache.cachedAt = Date()
        
        try context.save()
    }
    
    // 캐시 전체 삭제
    public func clear(status: TravelStatus) async throws {
        let context = makeContext()
        guard let statusCache = try fetchCache(for: status, in: context) else {
            return
        }
        context.delete(statusCache)
        try context.save()
    }
}

private extension TravelLocalDataSource {
    func makeContext() -> ModelContext {
        ModelContext(container)
    }
    
    // 모든 캐시 fetch
    func fetchAllCaches(
        in context: ModelContext
    ) throws -> [TravelCacheEntity] {
        var descriptor = FetchDescriptor<TravelCacheEntity>()
        descriptor.relationshipKeyPathsForPrefetching = [
            \TravelCacheEntity.travels
        ]
        return try context.fetch(descriptor)
    }
    
    // 상태별 캐시 fetch
    func fetchCache(
        for status: TravelStatus,
        in context: ModelContext
    ) throws -> TravelCacheEntity? {
        try fetchAllCaches(in: context)
            .first { $0.statusRawValue == status.rawValue }
    }
    
    // 만료 캐시 삭제
    func purgeExpiredCaches(
        _ caches: [TravelCacheEntity],
        in context: ModelContext
    ) throws -> [TravelCacheEntity] {
        
        let validCaches = caches.filter { cache in
            if cache.isExpired {
                context.delete(cache)
                return false
            }
            return true
        }
        
        if validCaches.count != caches.count {
            try context.save()
        }
        
        return validCaches
    }
}
