//
//  SettlementDTO.swift
//  Data
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation
import Domain

public struct SettlementDTO: Codable {
    public let id: String
    public let fromMember: String
    public let toMember: String
    public let amount: Double
    public let status: String
    public let updatedAt: String?

    public init(
        id: String,
        fromMember: String,
        toMember: String,
        amount: Double,
        status: String,
        updatedAt: String?
    ) {
        self.id = id
        self.fromMember = fromMember
        self.toMember = toMember
        self.amount = amount
        self.status = status
        self.updatedAt = updatedAt
    }
}

extension SettlementDTO {
    func toDomain() -> Settlement {
        let settlementStatus = SettlementStatus(rawValue: status) ?? .pending

        let updatedDate: Date? = {
            guard let updatedAt = updatedAt else { return nil }
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter.date(from: updatedAt)
        }()

        return Settlement(
            id: id,
            fromMemberName: fromMember,
            toMemberName: toMember,
            amount: amount,
            status: settlementStatus,
            updatedAt: updatedDate
        )
    }
}
