//
//  TravelSettlement.swift
//  Domain
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation

public struct TravelSettlement: Equatable, Hashable {
    public let balances: [MemberBalance]
    public let savedSettlements: [Settlement]
    public let recommendedSettlements: [Settlement]

    public init(
        balances: [MemberBalance],
        savedSettlements: [Settlement],
        recommendedSettlements: [Settlement]
    ) {
        self.balances = balances
        self.savedSettlements = savedSettlements
        self.recommendedSettlements = recommendedSettlements
    }
}
