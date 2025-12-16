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
    @Dependency(\.travelRepository) private var repository: TravelRepositoryProtocol
    
    public init() {}
    
    public func execute(id: String) async throws -> Travel {
        try await repository.fetchTravelDetail(id: id)
    }
}


// MARK: - DependencyKey
public enum FetchTravelDetailUseCaseDependencyKey: DependencyKey {
    public static var liveValue: any FetchTravelDetailUseCaseProtocol = FetchTravelDetailUseCase()
    
    public static var testValue: any FetchTravelDetailUseCaseProtocol = FetchTravelDetailUseCase()

    public static var previewValue: any FetchTravelDetailUseCaseProtocol = FetchTravelDetailUseCase()
}

public extension DependencyValues {
    var fetchTravelDetailUseCase: any FetchTravelDetailUseCaseProtocol {
        get { self[FetchTravelDetailUseCaseDependencyKey.self] }
        set { self[FetchTravelDetailUseCaseDependencyKey.self] = newValue }
    }
}
