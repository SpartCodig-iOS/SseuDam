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
    @Dependency(\.travelMemberRepository) private var repository: TravelMemberRepositoryProtocol

    public func execute(travelId: String, newOwnerId: String) async throws -> Travel {
        try await repository.delegateOwner(travelId: travelId, newOwnerId: newOwnerId)
    }
}

extension DelegateOwnerUseCase: DependencyKey {
    public static var liveValue: DelegateOwnerUseCaseProtocol = DelegateOwnerUseCase()

    public static var previewValue: DelegateOwnerUseCaseProtocol = DelegateOwnerUseCase()

    public static var testValue: DelegateOwnerUseCaseProtocol = DelegateOwnerUseCase()
}

public extension DependencyValues {
    var delegateOwnerUseCase: DelegateOwnerUseCaseProtocol {
        get { self[DelegateOwnerUseCase.self] }
        set { self[DelegateOwnerUseCase.self] = newValue }
    }
}

