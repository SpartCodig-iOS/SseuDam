//
//  TravelSettlement.swift
//  Domain
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation

public struct TravelSettlement: Equatable, Hashable {
    public let balances: [BalanceEntry]
    public let savedSettlements: [SettlementEntry]
    public let recommendedSettlements: [SettlementEntry]

    public init(
        balances: [BalanceEntry],
        savedSettlements: [SettlementEntry],
        recommendedSettlements: [SettlementEntry]
    ) {
        self.balances = balances
        self.savedSettlements = savedSettlements
        self.recommendedSettlements = recommendedSettlements
    }
}
