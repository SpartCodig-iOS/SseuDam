//
//  TravelLocalDataSource.swift
//  Data
//
//  Created by 김민희 on 12/15/25.
//

import Foundation
import Domain

public enum TravelCacheError: Error {
    case cacheDirectoryUnavailable
    case fileNotFound
    case dataCorrupted
}

public protocol TravelLocalDataSourceProtocol: Actor {
    func observe(status: TravelStatus) -> AsyncStream<[TravelCacheItemDTO]>
    func load(status: TravelStatus) async throws -> TravelCacheDTO?
    func save(_ cache: TravelCacheDTO) async throws
    func clear(status: TravelStatus)
}

public actor TravelLocalDataSource: TravelLocalDataSourceProtocol {
    private let fileManager = FileManager.default
    private lazy var cacheDirectory: URL? = {
        guard var cachesURL = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }
        cachesURL.append(
            path: TravelCacheConstants.directoryName,
            directoryHint: .isDirectory
        )
        try? fileManager.createDirectory(
            at: cachesURL,
            withIntermediateDirectories: true
        )
        return cachesURL
    }()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    // 여행 상태별로 AsyncStream 보관
    private var observers: [TravelStatus: [UUID: AsyncStream<[TravelCacheItemDTO]>.Continuation]] = [:]

    public init() {}

    public func observe(status: TravelStatus) -> AsyncStream<[TravelCacheItemDTO]> {
        // 캐시 파일이 갱신될 때마다 새로운 배열을 내보내며, 가지고 있는 캐시가 있다면 즉시 전달한다.
        AsyncStream { continuation in
            Task { [weak self] in
                guard let self else { return }
                let id = UUID()
                continuation.onTermination = { [weak self] _ in
                    Task { await self?.removeObserver(status: status, id: id) }
                }
                await self.storeObserver(status: status, id: id, continuation: continuation)
                if let cache = try? await self.load(status: status) {
                    continuation.yield(cache.travels)
                }
            }
        }
    }

    public func load(status: TravelStatus) async throws -> TravelCacheDTO? {
        let url = try cacheURL(for: status)
        guard fileManager.fileExists(atPath: url.path()) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let cache = try decoder.decode(TravelCacheDTO.self, from: data)
            if cache.isExpired {
                try? fileManager.removeItem(at: url)
                return nil
            }
            return cache
        } catch {
            try? fileManager.removeItem(at: url)
            throw TravelCacheError.dataCorrupted
        }
    }

    public func save(_ cache: TravelCacheDTO) async throws {
        let url = try cacheURL(for: cache.status)
        let data = try encoder.encode(cache)
        try data.write(to: url, options: [.atomic])
        notifyObservers(status: cache.status, travels: cache.travels)
    }

    public func clear(status: TravelStatus) {
        guard let url = try? cacheURL(for: status) else { return }
        try? fileManager.removeItem(at: url)
    }
}

private extension TravelLocalDataSource {
    func cacheURL(for status: TravelStatus) throws -> URL {
        guard var directory = cacheDirectory else {
            throw TravelCacheError.cacheDirectoryUnavailable
        }
        directory.append(
            path: "travel_\(status.rawValue).json",
            directoryHint: .notDirectory
        )
        return directory
    }

    func storeObserver(
        status: TravelStatus,
        id: UUID,
        continuation: AsyncStream<[TravelCacheItemDTO]>.Continuation
    ) {
        var continuations = observers[status] ?? [:]
        continuations[id] = continuation
        observers[status] = continuations
    }

    func removeObserver(status: TravelStatus, id: UUID) {
        var continuations = observers[status] ?? [:]
        continuations[id] = nil
        observers[status] = continuations.isEmpty ? nil : continuations
    }

    func notifyObservers(status: TravelStatus, travels: [TravelCacheItemDTO]) {
        guard let continuations = observers[status] else { return }
        continuations.values.forEach { $0.yield(travels) }
    }
}
