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
    private let repository: TravelRepositoryProtocol

    public init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: String, input: UpdateTravelInput) async throws -> Travel {
        try await repository.updateTravel(id: id, input: input)
    }
}

extension UpdateTravelUseCase: DependencyKey {
    public static var liveValue: UpdateTravelUseCaseProtocol = {
        UpdateTravelUseCase(repository: MockTravelRepository())
    }()

    public static var previewValue: UpdateTravelUseCaseProtocol = {
        UpdateTravelUseCase(repository: MockTravelRepository())
    }()

    public static var testValue: UpdateTravelUseCaseProtocol = {
        UpdateTravelUseCase(repository: MockTravelRepository())
    }()
}

public extension DependencyValues {
    var updateTravelUseCase: UpdateTravelUseCaseProtocol {
        get { self[UpdateTravelUseCase.self] }
        set { self[UpdateTravelUseCase.self] = newValue }
    }
}
