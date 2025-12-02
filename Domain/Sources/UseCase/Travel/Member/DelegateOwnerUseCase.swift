//
//  DelegateOwnerUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/30/25.
//

import Foundation
import Dependencies

public protocol DelegateOwnerUseCaseProtocol {
    func execute(travelId: String, newOwnerId: String) async throws -> Travel
}

public struct DelegateOwnerUseCase: DelegateOwnerUseCaseProtocol {
    private let repository: TravelMemberRepositoryProtocol

    public init(repository: TravelMemberRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(travelId: String, newOwnerId: String) async throws -> Travel {
        try await repository.delegateOwner(travelId: travelId, newOwnerId: newOwnerId)
    }
}

extension DelegateOwnerUseCase: DependencyKey {
    public static var liveValue: DelegateOwnerUseCaseProtocol = {
        DelegateOwnerUseCase(repository: MockTravelMemberRepository())
    }()

    public static var previewValue: DelegateOwnerUseCaseProtocol = {
        DelegateOwnerUseCase(repository: MockTravelMemberRepository())
    }()

    public static var testValue: DelegateOwnerUseCaseProtocol = {
        DelegateOwnerUseCase(repository: MockTravelMemberRepository())
    }()
}

public extension DependencyValues {
    var delegateOwnerUseCase: DelegateOwnerUseCaseProtocol {
        get { self[DelegateOwnerUseCase.self] }
        set { self[DelegateOwnerUseCase.self] = newValue }
    }
}

