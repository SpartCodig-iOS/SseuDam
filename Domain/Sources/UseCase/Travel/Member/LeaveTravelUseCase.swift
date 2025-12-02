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
    private let repository: TravelMemberRepositoryProtocol

    public init(repository: TravelMemberRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(travelId: String) async throws {
        try await repository.leaveTravel(travelId: travelId)
    }
}

extension LeaveTravelUseCase: DependencyKey {
    public static var liveValue: LeaveTravelUseCaseProtocol = {
        LeaveTravelUseCase(repository: MockTravelMemberRepository())
    }()

    public static var previewValue: LeaveTravelUseCaseProtocol = {
        LeaveTravelUseCase(repository: MockTravelMemberRepository())
    }()

    public static var testValue: LeaveTravelUseCaseProtocol = {
        LeaveTravelUseCase(repository: MockTravelMemberRepository())
    }()
}

public extension DependencyValues {
    var leaveTravelUseCase: LeaveTravelUseCaseProtocol {
        get { self[LeaveTravelUseCase.self] }
        set { self[LeaveTravelUseCase.self] = newValue }
    }
}
