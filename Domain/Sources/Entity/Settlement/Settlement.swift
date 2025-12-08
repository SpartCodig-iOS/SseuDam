//
//  Settlement.swift
//  Domain
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation

public enum SettlementStatus: String, Equatable, Hashable {
    case pending = "PENDING"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
}

public struct Settlement: Equatable, Hashable, Identifiable {
    public let id: String
    public let fromMemberId: String
    public let fromMemberName: String
    public let toMemberId: String
    public let toMemberName: String
    public let amount: Double
    public let status: SettlementStatus
    public let updatedAt: Date?

    public init(
        id: String,
        fromMemberId: String,
        fromMemberName: String,
        toMemberId: String,
        toMemberName: String,
        amount: Double,
        status: SettlementStatus,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.fromMemberId = fromMemberId
        self.fromMemberName = fromMemberName
        self.toMemberId = toMemberId
        self.toMemberName = toMemberName
        self.amount = amount
        self.status = status
        self.updatedAt = updatedAt
    }
}
