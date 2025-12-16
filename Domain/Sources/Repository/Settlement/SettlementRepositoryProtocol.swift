//
//  SettlementRepositoryProtocol.swift
//  Domain
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation
import Dependencies

public protocol SettlementRepositoryProtocol {
    func fetchSettlement(travelId: String) async throws -> TravelSettlement
}

// MARK: - Dependency
private enum SettlementRepositoryDepensencyKey: DependencyKey {
    static let liveValue: SettlementRepositoryProtocol = {
        fatalError("SettlementRepository liveValue not implemented")
    }()

    static let testValue: SettlementRepositoryProtocol = MockSettlementRepository()
}

extension DependencyValues {
    public var settlementRepository: SettlementRepositoryProtocol {
        get { self[SettlementRepositoryDepensencyKey.self] }
        set { self[SettlementRepositoryDepensencyKey.self] = newValue }
    }
}
