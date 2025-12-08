//
//  TravelSettlementDTO.swift
//  Data
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation
import Domain

public struct TravelSettlementDTO: Codable {
    public let balances: [MemberBalanceDTO]
    public let savedSettlements: [SettlementDTO]
    public let recommendedSettlements: [SettlementDTO]

    public init(
        balances: [MemberBalanceDTO],
        savedSettlements: [SettlementDTO],
        recommendedSettlements: [SettlementDTO]
    ) {
        self.balances = balances
        self.savedSettlements = savedSettlements
        self.recommendedSettlements = recommendedSettlements
    }
}

extension TravelSettlementDTO {
    func toDomain() -> TravelSettlement {
        return TravelSettlement(
            balances: balances.map { $0.toDomain() },
            savedSettlements: savedSettlements.map { $0.toDomain() },
            recommendedSettlements: recommendedSettlements.map { $0.toDomain() }
        )
    }
}
