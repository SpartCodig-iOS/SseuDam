//
//  MockFetchSettlementUseCase.swift
//  Domain
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation

public struct MockFetchSettlementUseCase: FetchSettlementUseCaseProtocol {
    public init() {}

    public func execute(travelId: String) async throws -> TravelSettlement {
        return TravelSettlement.mock
    }
}
