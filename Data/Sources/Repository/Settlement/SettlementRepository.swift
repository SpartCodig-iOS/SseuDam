//
//  SettlementRepository.swift
//  Data
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation
import Domain

public final class SettlementRepository: SettlementRepositoryProtocol {

    private let remote: SettlementRemoteDataSourceProtocol

    public init(remote: SettlementRemoteDataSourceProtocol) {
        self.remote = remote
    }

    public func fetchSettlement(travelId: String) async throws -> TravelSettlement {
        let dto = try await remote.fetchSettlement(travelId: travelId)
        return dto.toDomain()
    }
}
