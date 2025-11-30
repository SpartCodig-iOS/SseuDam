//
//  CreateTravelUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Dependencies

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

extension CreateTravelUseCase: DependencyKey {
    public static var liveValue: CreateTravelUseCaseProtocol = {
        CreateTravelUseCase(repository: MockTravelRepository())
    }()

    public static var previewValue: CreateTravelUseCaseProtocol = {
        CreateTravelUseCase(repository: MockTravelRepository())
    }()

    public static var testValue: CreateTravelUseCaseProtocol = {
        CreateTravelUseCase(repository: MockTravelRepository())
    }()
}

public extension DependencyValues {
    var createTravelUseCase: CreateTravelUseCaseProtocol {
        get { self[CreateTravelUseCase.self] }
        set { self[CreateTravelUseCase.self] = newValue }
    }
}
