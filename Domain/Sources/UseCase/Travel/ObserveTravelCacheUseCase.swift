//
//  ObserveTravelCacheUseCase.swift
//  Domain
//
//  Created by 김민희 on 12/15/25.
//

import Foundation
import Dependencies

public protocol ObserveTravelCacheUseCaseProtocol {
    func execute(status: TravelStatus) -> AsyncStream<[Travel]>
}

public struct ObserveTravelCacheUseCase: ObserveTravelCacheUseCaseProtocol {
    private let repository: TravelRepositoryProtocol

    public init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(status: TravelStatus) -> AsyncStream<[Travel]> {
        repository.observeCachedTravels(status: status)
    }
}

extension ObserveTravelCacheUseCase: DependencyKey {
    public static var liveValue: ObserveTravelCacheUseCaseProtocol = {
        ObserveTravelCacheUseCase(repository: MockTravelRepository())
    }()

    public static var previewValue: ObserveTravelCacheUseCaseProtocol = {
        ObserveTravelCacheUseCase(repository: MockTravelRepository())
    }()

    public static var testValue: ObserveTravelCacheUseCaseProtocol = {
        ObserveTravelCacheUseCase(repository: MockTravelRepository())
    }()
}

public extension DependencyValues {
    var observeTravelCacheUseCase: ObserveTravelCacheUseCaseProtocol {
        get { self[ObserveTravelCacheUseCase.self] }
        set { self[ObserveTravelCacheUseCase.self] = newValue }
    }
}
