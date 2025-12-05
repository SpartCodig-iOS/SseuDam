//
//  BalanceEntry.swift
//  Domain
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation

public struct BalanceEntry: Equatable, Hashable, Identifiable {
    public let id: String
    public let memberId: String
    public let name: String
    public let balance: Double

    public init(
        id: String,
        memberId: String,
        name: String,
        balance: Double
    ) {
        self.id = id
        self.memberId = memberId
        self.name = name
        self.balance = balance
    }
}
