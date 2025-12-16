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
    private let repository: TravelRepositoryProtocol

    public init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: String) async throws -> Travel? {
        try await repository.loadCachedTravel(id: id)
    }
}

extension LoadTravelDetailCacheUseCase: DependencyKey {
    public static var liveValue: any LoadTravelDetailCacheUseCaseProtocol = {
        LoadTravelDetailCacheUseCase(repository: MockTravelRepository())
    }()

    public static var previewValue: any LoadTravelDetailCacheUseCaseProtocol = {
        LoadTravelDetailCacheUseCase(repository: MockTravelRepository())
    }()

    public static var testValue: any LoadTravelDetailCacheUseCaseProtocol = {
        LoadTravelDetailCacheUseCase(repository: MockTravelRepository())
    }()
}

public extension DependencyValues {
    var loadTravelDetailCacheUseCase: any LoadTravelDetailCacheUseCaseProtocol {
        get { self[LoadTravelDetailCacheUseCase.self] }
        set { self[LoadTravelDetailCacheUseCase.self] = newValue }
    }
}
