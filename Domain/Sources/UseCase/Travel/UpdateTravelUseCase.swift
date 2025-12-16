//
//  UpdateTravelUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Dependencies

public protocol UpdateTravelUseCaseProtocol {
    func execute(id: String, input: UpdateTravelInput) async throws -> Travel
}

public struct UpdateTravelUseCase: UpdateTravelUseCaseProtocol {
    @Dependency(\.travelRepository) private var repository: TravelRepositoryProtocol
    
    public init() {}

    public func execute(id: String, input: UpdateTravelInput) async throws -> Travel {
        try await repository.updateTravel(id: id, input: input)
    }
}

extension UpdateTravelUseCase: DependencyKey {
    public static var liveValue: UpdateTravelUseCaseProtocol = UpdateTravelUseCase()
    public static var previewValue: UpdateTravelUseCaseProtocol = UpdateTravelUseCase()
    public static var testValue: UpdateTravelUseCaseProtocol = UpdateTravelUseCase()
}

public extension DependencyValues {
    var updateTravelUseCase: UpdateTravelUseCaseProtocol {
        get { self[UpdateTravelUseCase.self] }
        set { self[UpdateTravelUseCase.self] = newValue }
    }
}
