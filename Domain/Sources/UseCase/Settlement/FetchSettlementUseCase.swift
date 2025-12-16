//
//  FetchSettlementUseCase.swift
//  Domain
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation
import Dependencies

public protocol FetchSettlementUseCaseProtocol {
    func execute(travelId: String) async throws -> TravelSettlement
}


public struct FetchSettlementUseCase: FetchSettlementUseCaseProtocol {
    @Dependency(\.settlementRepository) private var repository: SettlementRepositoryProtocol

    public func execute(travelId: String) async throws -> TravelSettlement {
        return try await repository.fetchSettlement(travelId: travelId)
    }
}

// MARK: - DependencyKey
public enum FetchSettlementUseCaseDependencyKey: DependencyKey {
    public static var liveValue: any FetchSettlementUseCaseProtocol = FetchSettlementUseCase()

    public static var testValue: any FetchSettlementUseCaseProtocol = MockFetchSettlementUseCase()

    public static var previewValue: any FetchSettlementUseCaseProtocol = MockFetchSettlementUseCase()
}

public extension DependencyValues {
    var fetchSettlementUseCase: any FetchSettlementUseCaseProtocol {
        get { self[FetchSettlementUseCaseDependencyKey.self] }
        set { self[FetchSettlementUseCaseDependencyKey.self] = newValue }
    }
}
