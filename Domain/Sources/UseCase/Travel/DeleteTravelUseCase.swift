//
//  DeleteTravelUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

protocol DeleteTravelUseCase {
    func execute(id: String) async throws
}

final class DeleteTravelUseCaseImpl: DeleteTravelUseCase {
    private let repository: TravelRepositoryProtocol
    
    init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: String) async throws {
        try await repository.deleteTravel(id: id)
    }
}
