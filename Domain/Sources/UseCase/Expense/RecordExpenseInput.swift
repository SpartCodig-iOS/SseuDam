//
//  RecordExpenseInput.swift
//  Domain
//
//  Created by 홍석현 on 11/17/25.
//

import Foundation

public struct RecordExpenseInput: Codable {
    public let tripId: String
    public let payerId: String
    public let title: String
    public let note: String?
    public let amount: Double
    public let currency: String // 통화 코드 (JPY, KRW 등)
    public let expenseDate: String
    public let category: ExpenseCategory
    public let participantIds: [String]
}
