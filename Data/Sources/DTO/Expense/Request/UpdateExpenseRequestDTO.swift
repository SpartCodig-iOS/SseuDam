//
//  UpdateExpenseRequestDTO.swift
//  Data
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import Domain

public struct UpdateExpenseRequestDTO: Encodable {
    let title: String
    let amount: Double
    let currency: String
    let expenseDate: String
    let category: String
    let participantIds: [String]
}

extension Expense {
    func toUpdateRequestDTO() -> UpdateExpenseRequestDTO {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        let dateString = dateFormatter.string(from: expenseDate)

        return UpdateExpenseRequestDTO(
            title: title,
            amount: amount,
            currency: currency,
            expenseDate: dateString,
            category: category.rawValue,
            participantIds: participants.map { $0.id }
        )
    }
}
