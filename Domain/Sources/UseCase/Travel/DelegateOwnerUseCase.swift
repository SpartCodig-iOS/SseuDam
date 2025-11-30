//
//  DelegateOwnerUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/30/25.
//

import Foundation

public protocol DelegateOwnerUseCaseProtocol {
    func execute(travelId: String, newOwnerId: String) async throws -> Travel
}

public final class DelegateOwnerUseCase: DelegateOwnerUseCaseProtocol {
    private let repository: TravelRepositoryProtocol

    public init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(travelId: String, newOwnerId: String) async throws -> Travel {
        try await repository.delegateOwner(travelId: travelId, newOwnerId: newOwnerId)
    }
}

