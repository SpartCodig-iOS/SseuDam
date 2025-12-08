//
//  FetchSettlementUseCaseProtocol.swift
//  Domain
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation

public protocol FetchSettlementUseCaseProtocol {
    func execute(travelId: String) async throws -> TravelSettlement
}
