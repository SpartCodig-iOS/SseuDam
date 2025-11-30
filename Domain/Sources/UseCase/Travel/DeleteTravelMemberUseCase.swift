//
//  DeleteTravelMemberUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/30/25.
//

import Foundation

public protocol DeleteTravelMemberUseCaseProtocol {
    func execute(travelId: String, memberId: String) async throws
}

public final class DeleteTravelMemberUseCase: DeleteTravelMemberUseCaseProtocol {
    private let repository: TravelRepositoryProtocol

    public init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(travelId: String, memberId: String) async throws {
        try await repository.deleteMember(travelId: travelId, memberId: memberId)
    }
}
