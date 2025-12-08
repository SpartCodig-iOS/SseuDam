//
//  SettlementRepositoryProtocol.swift
//  Domain
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation

public protocol SettlementRepositoryProtocol {
    func fetchSettlement(travelId: String) async throws -> TravelSettlement
}
