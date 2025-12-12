//
//  ExpenseInput.swift
//  Domain
//
//  Created by 홍석현 on 11/30/25.
//

import Foundation

public struct ExpenseInput {
    public let title: String
    public let amount: Double
    public let currency: String
    public let expenseDate: Date
    public let category: ExpenseCategory
    public let payerId: String
    public let participantIds: [String]

    public init(
        title: String,
        amount: Double,
        currency: String,
        expenseDate: Date,
        category: ExpenseCategory,
        payerId: String,
        participantIds: [String]
    ) {
        self.title = title
        self.amount = amount
        self.currency = currency
        self.expenseDate = expenseDate
        self.category = category
        self.payerId = payerId
        self.participantIds = participantIds
    }
}

// MARK: - Validation
extension ExpenseInput {
    public func validate() throws {
        // 금액 검증
        guard amount > 0 else {
            throw ExpenseError.invalidAmount(amount)
        }

        // 제목 검증
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ExpenseError.emptyTitle
        }

        // 참가자 검증
        guard !participantIds.isEmpty else {
            throw ExpenseError.invalidParticipants
        }

        // 지불자가 참가자 목록에 있는지 검증
        guard participantIds.contains(payerId) else {
            throw ExpenseError.payerNotInParticipants
        }
    }
}

// MARK: - Helper
extension ExpenseInput {
    public func formatExpenseDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: expenseDate)
    }
}
