//
//  TravelMemberRepositoryProtocol.swift
//  Domain
//
//  Created by 김민희 on 12/1/25.
//

import Foundation
import Dependencies

public protocol TravelMemberRepositoryProtocol {
    func deleteMember(travelId: String, memberId: String) async throws
    func joinTravel(inviteCode: String) async throws -> Travel
    func delegateOwner(travelId: String, newOwnerId: String) async throws -> Travel
    func leaveTravel(travelId: String) async throws
    func fetchMember(travelId: String) async throws -> MyTravelMember
}

// MARK: - Dependency
private enum TravelMemberRepositoryDepensencyKey: DependencyKey {
    static let liveValue: TravelMemberRepositoryProtocol = {
        fatalError("TravelMemberRepository liveValue not implemented")
    }()

    static let testValue: TravelMemberRepositoryProtocol = MockTravelMemberRepository()
}

extension DependencyValues {
    public var travelMemberRepository: TravelMemberRepositoryProtocol {
        get { self[TravelMemberRepositoryDepensencyKey.self] }
        set { self[TravelMemberRepositoryDepensencyKey.self] = newValue }
    }
}
