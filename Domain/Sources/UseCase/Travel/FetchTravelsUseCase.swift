//
//  FetchTravelsUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Dependencies

public protocol FetchTravelsUseCaseProtocol {
    func execute(input: FetchTravelsInput) async throws -> [Travel]
}

public struct FetchTravelsUseCase: FetchTravelsUseCaseProtocol {
    private let repository: TravelRepositoryProtocol
    
    public init(repository: TravelRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(input: FetchTravelsInput) async throws -> [Travel] {
        try await repository.fetchTravels(input: input)
    }
}

extension FetchTravelsUseCase: DependencyKey {
    public static var liveValue: FetchTravelsUseCaseProtocol = {
        FetchTravelsUseCase(repository: MockTravelRepository())
    }()

    public static var previewValue: FetchTravelsUseCaseProtocol = {
        FetchTravelsUseCase(repository: MockTravelRepository())
    }()

    public static var testValue: FetchTravelsUseCaseProtocol = {
        FetchTravelsUseCase(repository: MockTravelRepository())
    }()
}

public extension DependencyValues {
    var fetchTravelsUseCase: FetchTravelsUseCaseProtocol {
        get { self[FetchTravelsUseCase.self] }
        set { self[FetchTravelsUseCase.self] = newValue }
    }
}
