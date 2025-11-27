//
//  Expense.swift
//  Domain
//
//  Created by 홍석현 on 11/21/25.
//

import Foundation

public struct Expense: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let note: String?
    public let amount: Double
    public let currency: String
    public let convertedAmount: Double // 환산 금액
    public let expenseDate: Date
    public let category: ExpenseCategory
    public let payerId: String
    public let payerName: String
    public let participants: [TravelMember]

    public init(
        id: String,
        title: String,
        note: String?,
        amount: Double,
        currency: String,
        convertedAmount: Double,
        expenseDate: Date,
        category: ExpenseCategory,
        payerId: String,
        payerName: String,
        participants: [TravelMember]
    ) {
        self.id = id
        self.title = title
        self.note = note
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

extension Expense {
    public func validate() throws {
        // 금액 검증
        guard amount > 0 else {
            throw ExpenseError.invalidAmount(amount)
        }
        
        // 제목 검증
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ExpenseError.emptyTitle
        }
        
        // 날짜 검증
        guard expenseDate <= Date() else {
            throw ExpenseError.invalidDate
        }
        
        // 참가자 검증
        guard !participants.isEmpty else {
            throw ExpenseError.invalidParticipants
        }
        
        // 지불자가 참가자 목록에 있는지 검증
        guard participants.contains(where: { $0.id == payerId }) else {
            throw ExpenseError.payerNotInParticipants
        }
    }
}
