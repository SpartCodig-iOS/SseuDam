//
//  FetchTravelsUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

public protocol FetchTravelsUseCaseProtocol {
    func excute(input: FetchTravelsInput) async throws -> [Travel]
}

public final class FetchTravelsUseCase: FetchTravelsUseCaseProtocol {
    private let repository: TravelRepositoryProtocol
    
    public init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }
    
    public func excute(input: FetchTravelsInput) async throws -> [Travel] {
        try await repository.fetchTravels(input: input)
    }
}
