//
//  ExpenseLocalDataSource.swift
//  Data
//
//  Created by 홍석현 on 12/9/25.
//

import Foundation
import Domain

public enum ExpenseCacheError: Error {
    case cacheDirectoryUnavailable
    case fileNotFound
    case dataCorrupted
}

public protocol ExpenseLocalDataSourceProtocol {
    func loadCachedExpenses(_ travelId: String) async throws -> ExpenseCache
    func saveCachedExpenses(_ cache: ExpenseCache) async throws
}

public actor ExpenseLocalDataSource: ExpenseLocalDataSourceProtocol {
    private let fileManager = FileManager.default
    private lazy var cacheDirectory: URL? = {
        guard var cachesURL = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }
        cachesURL.append(
            path: "expenses",
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
    
    
    public init() {}
    
    private func cacheURL(for travelId: String) throws -> URL {
        guard var directory = cacheDirectory else {
            throw ExpenseCacheError.cacheDirectoryUnavailable
        }
        
        directory.append(path: "travel_\(travelId).json", directoryHint: .notDirectory)
        return directory
    }
    
    public func loadCachedExpenses(_ travelId: String) async throws -> ExpenseCache {
        let url = try cacheURL(for: travelId)
        
        guard fileManager.fileExists(atPath: url.path()) else {
            throw ExpenseCacheError.cacheDirectoryUnavailable
        }
        
        do {
            let data = try Data(contentsOf: url)
            let cache = try decoder.decode(ExpenseCache.self, from: data)
            
            if cache.isExpired {
                clearCache(travelId)
                throw ExpenseCacheError.dataCorrupted
            }
            return cache
        } catch {
            try? fileManager.removeItem(at: url)
            throw ExpenseCacheError.dataCorrupted
        }
    }
    
    public func saveCachedExpenses(_ cache: ExpenseCache) async throws {
        let url = try cacheURL(for: cache.travelId)
        let data = try encoder.encode(cache)

        try data.write(to: url, options: [.atomic])
    }
    
    private func clearCache(_ travelId: String) {
        guard let directory = cacheDirectory else { return }
        try? fileManager.removeItem(at: directory)

        // 디렉토리 재생성
        try? fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
    }
}
