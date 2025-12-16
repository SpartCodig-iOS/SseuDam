//
//  LoadTravelCacheUseCase.swift
//  Domain
//
//  Created by 김민희 on 12/15/25.
//

import Foundation
import Dependencies

public protocol LoadTravelCacheUseCaseProtocol {
    func execute(status: TravelStatus) async throws -> [Travel]?
}

public struct LoadTravelCacheUseCase: LoadTravelCacheUseCaseProtocol {
    @Dependency(\.travelRepository) private var repository: TravelRepositoryProtocol
    
    public init() {}

    public func execute(status: TravelStatus) async throws -> [Travel]? {
        try await repository.loadCachedTravels(status: status)
    }
}

extension LoadTravelCacheUseCase: DependencyKey {
    public static var liveValue: LoadTravelCacheUseCaseProtocol = LoadTravelCacheUseCase()
    public static var previewValue: LoadTravelCacheUseCaseProtocol = LoadTravelCacheUseCase()
    public static var testValue: LoadTravelCacheUseCaseProtocol = LoadTravelCacheUseCase()
}

public extension DependencyValues {
    var loadTravelCacheUseCase: LoadTravelCacheUseCaseProtocol {
        get { self[LoadTravelCacheUseCase.self] }
        set { self[LoadTravelCacheUseCase.self] = newValue }
    }
}
