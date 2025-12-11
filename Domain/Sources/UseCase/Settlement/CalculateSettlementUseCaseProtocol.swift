//
//  CalculateSettlementUseCaseProtocol.swift
//  Domain
//
//  Created by 홍석현 on 12/10/25.
//

import Foundation

public protocol CalculateSettlementUseCaseProtocol {
    func execute(
        expenses: [Expense],
        members: [TravelMember],
        currentUserId: String?
    ) -> SettlementCalculation
}
