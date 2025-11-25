//
//  CreateTravelUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

public protocol CreateTravelUseCaseProtocol {
    func excute(input: CreateTravelInput) async throws -> Travel
}

public final class CreateTravelUseCase: CreateTravelUseCaseProtocol {
    private let repository: TravelRepositoryProtocol
    
    public init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }
    
    public func excute(input: CreateTravelInput) async throws -> Travel {
        try await repository.createTravel(input: input)
    }
}
