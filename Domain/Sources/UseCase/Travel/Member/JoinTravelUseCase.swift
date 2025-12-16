//
//  JoinTravelUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/30/25.
//

import Foundation
import Dependencies

public protocol JoinTravelUseCaseProtocol {
    func execute(inviteCode: String) async throws -> Travel
}

public struct JoinTravelUseCase: JoinTravelUseCaseProtocol {
    @Dependency(\.travelMemberRepository) private var repository: TravelMemberRepositoryProtocol

    public init() {}

    public func execute(inviteCode: String) async throws -> Travel {
        try await repository.joinTravel(inviteCode: inviteCode)
    }
}

extension JoinTravelUseCase: DependencyKey {
    public static var liveValue: JoinTravelUseCaseProtocol = JoinTravelUseCase()

    public static var previewValue: JoinTravelUseCaseProtocol = JoinTravelUseCase()

    public static var testValue: JoinTravelUseCaseProtocol = JoinTravelUseCase()
}

public extension DependencyValues {
    var joinTravelUseCase: JoinTravelUseCaseProtocol {
        get { self[JoinTravelUseCase.self] }
        set { self[JoinTravelUseCase.self] = newValue }
    }
}
