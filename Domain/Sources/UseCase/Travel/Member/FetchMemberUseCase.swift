//
//  FetchMemberUseCase.swift
//  Domain
//
//  Created by 김민희 on 12/10/25.
//

import Foundation
import Dependencies

public protocol FetchMemberUseCaseProtocol {
    func execute(travelId: String) async throws -> MyTravelMember
}

public struct FetchMemberUseCase: FetchMemberUseCaseProtocol {
    private let repository: TravelMemberRepositoryProtocol
    
    public init(repository: TravelMemberRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(travelId: String) async throws -> MyTravelMember {
        try await repository.fetchMember(travelId: travelId)
    }
}

extension FetchMemberUseCase: DependencyKey {
    public static var liveValue: FetchMemberUseCaseProtocol = {
        FetchMemberUseCase(repository: MockTravelMemberRepository())
    }()

    public static var previewValue: FetchMemberUseCaseProtocol = {
        FetchMemberUseCase(repository: MockTravelMemberRepository())
    }()

    public static var testValue: FetchMemberUseCaseProtocol = {
        FetchMemberUseCase(repository: MockTravelMemberRepository())
    }()
}

public extension DependencyValues {
    var fetchMemberUseCase: FetchMemberUseCaseProtocol {
        get { self[FetchMemberUseCase.self] }
        set { self[FetchMemberUseCase.self] = newValue }
    }
}
