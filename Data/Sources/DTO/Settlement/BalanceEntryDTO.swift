//
//  BalanceEntryDTO.swift
//  Data
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation
import Domain

public struct BalanceEntryDTO: Codable {
    public let memberId: String
    public let name: String
    public let balance: Double

    public init(
        memberId: String,
        name: String,
        balance: Double
    ) {
        self.memberId = memberId
        self.name = name
        self.balance = balance
    }
}

extension BalanceEntryDTO {
    func toDomain() -> BalanceEntry {
        return BalanceEntry(
            id: memberId,
            memberId: memberId,
            name: name,
            balance: balance
        )
    }
}
