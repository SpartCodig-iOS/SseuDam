//
//  DeleteTravelMemberUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/30/25.
//

import Foundation
import Dependencies

public protocol DeleteTravelMemberUseCaseProtocol {
    func execute(travelId: String, memberId: String) async throws
}

public struct DeleteTravelMemberUseCase: DeleteTravelMemberUseCaseProtocol {
    @Dependency(\.travelMemberRepository) private var repository: TravelMemberRepositoryProtocol

    public func execute(travelId: String, memberId: String) async throws {
        try await repository.deleteMember(travelId: travelId, memberId: memberId)
    }
}

extension DeleteTravelMemberUseCase: DependencyKey {
    public static var liveValue: DeleteTravelMemberUseCaseProtocol = DeleteTravelMemberUseCase()

    public static var previewValue: DeleteTravelMemberUseCaseProtocol = DeleteTravelMemberUseCase()

    public static var testValue: DeleteTravelMemberUseCaseProtocol = DeleteTravelMemberUseCase()
}

public extension DependencyValues {
    var deleteTravelMemberUseCase: DeleteTravelMemberUseCaseProtocol {
        get { self[DeleteTravelMemberUseCase.self] }
        set { self[DeleteTravelMemberUseCase.self] = newValue }
    }
}
