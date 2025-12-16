//
//  LoadTravelDetailCacheUseCase.swift
//  Domain
//
//  Created by 김민희 on 12/16/25.
//

import Foundation
import Dependencies

public protocol LoadTravelDetailCacheUseCaseProtocol {
    func execute(id: String) async throws -> Travel?
}

public struct LoadTravelDetailCacheUseCase: LoadTravelDetailCacheUseCaseProtocol {
    @Dependency(\.travelRepository) private var repository: TravelRepositoryProtocol

    public init() {}

    public func execute(id: String) async throws -> Travel? {
        try await repository.loadCachedTravel(id: id)
    }
}

extension LoadTravelDetailCacheUseCase: DependencyKey {
    public static let liveValue: any LoadTravelDetailCacheUseCaseProtocol = LoadTravelDetailCacheUseCase()
    public static let previewValue: any LoadTravelDetailCacheUseCaseProtocol = LoadTravelDetailCacheUseCase()
    public static let testValue: any LoadTravelDetailCacheUseCaseProtocol = LoadTravelDetailCacheUseCase()
}

public extension DependencyValues {
    var loadTravelDetailCacheUseCase: any LoadTravelDetailCacheUseCaseProtocol {
        get { self[LoadTravelDetailCacheUseCase.self] }
        set { self[LoadTravelDetailCacheUseCase.self] = newValue }
    }
}
