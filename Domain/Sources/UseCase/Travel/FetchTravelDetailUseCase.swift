//
//  FetchTravelDetailUseCase.swift
//  Domain
//
//  Created by SseuDam on 2025.
//

import Foundation

public protocol FetchTravelDetailUseCaseProtocol {
    func execute(id: String) async throws -> Travel
}

public final class FetchTravelDetailUseCase: FetchTravelDetailUseCaseProtocol {
    private let repository: TravelRepositoryProtocol
    
    public init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(id: String) async throws -> Travel {
        try await repository.fetchTravelDetail(id: id)
    }
}
