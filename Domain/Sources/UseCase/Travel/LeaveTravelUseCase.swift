//
//  LeaveTravelUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/30/25.
//

import Foundation

public protocol LeaveTravelUseCaseProtocol {
    func execute(travelId: String) async throws
}

public final class LeaveTravelUseCase: LeaveTravelUseCaseProtocol {
    private let repository: TravelRepositoryProtocol

    public init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(travelId: String) async throws {
        try await repository.leaveTravel(travelId: travelId)
    }
}

