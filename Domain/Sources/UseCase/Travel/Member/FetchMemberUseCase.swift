//
//  FetchMemberUseCase.swift
//  Domain
//
//  Created by 김민희 on 12/10/25.
//

import Foundation

public protocol FetchMemberUseCaseProtocol {
    func execute(travelId: String) async throw -> [TravelMember]
}

public struct FetchMemberUseCase: FetchMemberUseCaseProtocol {
    private let repository: TravelMemberRepositoryProtocol
    
    public init(repository: TravelMemberRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(travelId: String) async throws -> [TravelMember] {
        try await repository.fetchMember(travelId: travelId)
    }
}
