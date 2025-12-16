//
//  CreateTravelUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Dependencies

public protocol CreateTravelUseCaseProtocol {
    func execute(input: CreateTravelInput) async throws -> Travel
}

public struct CreateTravelUseCase: CreateTravelUseCaseProtocol {
    @Dependency(\.travelRepository) private var repository: TravelRepositoryProtocol
    
    public init() {}
    
    public func execute(input: CreateTravelInput) async throws -> Travel {
        try await repository.createTravel(input: input)
    }
}

extension CreateTravelUseCase: DependencyKey {
    public static var liveValue: CreateTravelUseCaseProtocol = CreateTravelUseCase()
    public static var previewValue: CreateTravelUseCaseProtocol = CreateTravelUseCase()
    public static var testValue: CreateTravelUseCaseProtocol = CreateTravelUseCase()
}

public extension DependencyValues {
    var createTravelUseCase: CreateTravelUseCaseProtocol {
        get { self[CreateTravelUseCase.self] }
        set { self[CreateTravelUseCase.self] = newValue }
    }
}
