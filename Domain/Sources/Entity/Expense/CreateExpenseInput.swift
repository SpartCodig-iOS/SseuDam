//
//  CreateExpenseInput.swift
//  Domain
//
//  Created by 홍석현 on 11/30/25.
//

import Foundation

public struct CreateExpenseInput {
    public let title: String
    public let amount: Double
    public let currency: String
    public let convertedAmount: Double
    public let expenseDate: Date
    public let category: ExpenseCategory
    public let payerId: String
    public let payerName: String
    public let participants: [TravelMember]

    public init(
        title: String,
        amount: Double,
        currency: String,
        convertedAmount: Double,
        expenseDate: Date,
        category: ExpenseCategory,
        payerId: String,
        payerName: String,
        participants: [TravelMember]
    ) {
        self.title = title
        self.amount = amount
        self.currency = currency
        self.convertedAmount = convertedAmount
        self.expenseDate = expenseDate
        self.category = category
        self.payerId = payerId
        self.payerName = payerName
        self.participants = participants
    }
}
