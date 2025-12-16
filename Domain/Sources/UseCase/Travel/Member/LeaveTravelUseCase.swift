//
//  LeaveTravelUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/30/25.
//

import Foundation
import Dependencies

public protocol LeaveTravelUseCaseProtocol {
    func execute(travelId: String) async throws
}

public struct LeaveTravelUseCase: LeaveTravelUseCaseProtocol {
    @Dependency(\.travelMemberRepository) private var repository: TravelMemberRepositoryProtocol

    public init() {}

    public func execute(travelId: String) async throws {
        try await repository.leaveTravel(travelId: travelId)
    }
}

extension LeaveTravelUseCase: DependencyKey {
    public static var liveValue: LeaveTravelUseCaseProtocol = LeaveTravelUseCase()

    public static var previewValue: LeaveTravelUseCaseProtocol = LeaveTravelUseCase()

    public static var testValue: LeaveTravelUseCaseProtocol = LeaveTravelUseCase()
}

public extension DependencyValues {
    var leaveTravelUseCase: LeaveTravelUseCaseProtocol {
        get { self[LeaveTravelUseCase.self] }
        set { self[LeaveTravelUseCase.self] = newValue }
    }
}
