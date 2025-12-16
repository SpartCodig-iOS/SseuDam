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
    @Dependency(\.travelRepository) private var repository: TravelRepositoryProtocol
    
    public init() {}
    
    public func execute(input: FetchTravelsInput) async throws -> [Travel] {
        try await repository.fetchTravels(input: input)
    }
}

extension FetchTravelsUseCase: DependencyKey {
    public static var liveValue: FetchTravelsUseCaseProtocol = FetchTravelsUseCase()
    public static var previewValue: FetchTravelsUseCaseProtocol = FetchTravelsUseCase()
    public static var testValue: FetchTravelsUseCaseProtocol = FetchTravelsUseCase()
}

public extension DependencyValues {
    var fetchTravelsUseCase: FetchTravelsUseCaseProtocol {
        get { self[FetchTravelsUseCase.self] }
        set { self[FetchTravelsUseCase.self] = newValue }
    }
}
