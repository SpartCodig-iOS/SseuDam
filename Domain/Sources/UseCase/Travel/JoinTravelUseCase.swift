//
//  JoinTravelUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/30/25.
//

import Foundation

public protocol JoinTravelUseCaseProtocol {
    func execute(inviteCode: String) async throws -> Travel
}

public final class JoinTravelUseCase: JoinTravelUseCaseProtocol {
    private let repository: TravelRepositoryProtocol

    public init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(inviteCode: String) async throws -> Travel {
        try await repository.joinTravel(inviteCode: inviteCode)
    }
}

