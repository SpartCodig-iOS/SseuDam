//
//  FetchTravelDetailUseCase.swift
//  Domain
//
//  Created by SseuDam on 2025.
//

import Foundation
import Dependencies

public protocol FetchTravelDetailUseCaseProtocol {
    func execute(id: String) async throws -> Travel
}

public struct FetchTravelDetailUseCase: FetchTravelDetailUseCaseProtocol {
    private let repository: TravelRepositoryProtocol
    
    public init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(id: String) async throws -> Travel {
        try await repository.fetchTravelDetail(id: id)
    }
}


// MARK: - DependencyKey
public enum FetchTravelDetailUseCaseDependencyKey: DependencyKey {
    public static var liveValue: any FetchTravelDetailUseCaseProtocol = MockFetchTravelDetailUseCase()
    
    public static var testValue: any FetchTravelDetailUseCaseProtocol = MockFetchTravelDetailUseCase()

    public static var previewValue: any FetchTravelDetailUseCaseProtocol = MockFetchTravelDetailUseCase()
}

public extension DependencyValues {
    var fetchTravelDetailUseCase: any FetchTravelDetailUseCaseProtocol {
        get { self[FetchTravelDetailUseCaseDependencyKey.self] }
        set { self[FetchTravelDetailUseCaseDependencyKey.self] = newValue }
    }
}
