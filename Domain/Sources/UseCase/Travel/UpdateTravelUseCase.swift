//
//  UpdateTravelUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

protocol UpdateTravelUseCase {
    func execute(id: String, input: UpdateTravelInput) async throws -> Travel
}

final class UpdateTravelUseCaseImpl: UpdateTravelUseCase {
    private let repository: TravelRepositoryProtocol

    init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String, input: UpdateTravelInput) async throws -> Travel {
        try await repository.updateTravel(id: id, input: input)
    }
}
