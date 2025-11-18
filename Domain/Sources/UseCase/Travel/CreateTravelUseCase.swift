//
//  CreateTravelUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

protocol CreateTravelUseCaseProtocol {
    func excute(input: CreateTravelInput) async throws -> Travel
}

final class CreateTravelUseCase: CreateTravelUseCaseProtocol {
    private let repository: TravelRepositoryProtocol
    
    init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }
    
    func excute(input: CreateTravelInput) async throws -> Travel {
        try await repository.createTravel(input: input)
    }
}
