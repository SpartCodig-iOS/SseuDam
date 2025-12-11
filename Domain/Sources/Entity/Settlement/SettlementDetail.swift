//
//  SettlementDetail.swift
//  Domain
//
//  Created by SseuDam on 2025.
//

import Foundation

// MARK: - Member Settlement Detail
public struct MemberSettlementDetail: Equatable, Identifiable {
    public let id: String
    public let memberId: String
    public let memberName: String
    public let netBalance: Double
    public let totalPaid: Double
    public let totalOwe: Double
    public let paidExpenses: [ExpenseDetail]
    public let sharedExpenses: [ExpenseDetail]

    public init(
        id: String,
        memberId: String,
        memberName: String,
        netBalance: Double,
        totalPaid: Double,
        totalOwe: Double,
        paidExpenses: [ExpenseDetail],
        sharedExpenses: [ExpenseDetail]
    ) {
        self.id = id
        self.memberId = memberId
        self.memberName = memberName
        self.netBalance = netBalance
        self.totalPaid = totalPaid
        self.totalOwe = totalOwe
        self.paidExpenses = paidExpenses
        self.sharedExpenses = sharedExpenses
    }
}

// MARK: - Expense Detail
public struct ExpenseDetail: Equatable, Identifiable {
    public let id: String
    public let title: String
    public let amount: Double
    public let shareAmount: Double
    public let participantCount: Int
    public let expenseDate: Date

    public init(
        id: String,
        title: String,
        amount: Double,
        shareAmount: Double,
        participantCount: Int,
        expenseDate: Date
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.shareAmount = shareAmount
        self.participantCount = participantCount
        self.expenseDate = expenseDate
    }
}
