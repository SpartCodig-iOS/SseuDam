//
//  CreateExpenseRequestDTO.swift
//  Data
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import Domain

public struct CreateExpenseRequestDTO: Encodable {
    let title: String
    let note: String?
    let amount: Double
    let currency: String
    let expenseDate: String
    let category: String
    let participantIds: [String]

    var toDictionary: [String: Any] {
        var dict: [String: Any] = [
            "title": title,
            "amount": amount,
            "currency": currency,
            "expenseDate": expenseDate,
            "category": category,
            "participantIds": participantIds
        ]
        
        if let note = note {
            dict["note"] = note
        }
        
        return dict
    }
}

extension Expense {
    func toCreateRequestDTO() -> CreateExpenseRequestDTO {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        let dateString = dateFormatter.string(from: expenseDate)
        
        return CreateExpenseRequestDTO(
            title: title,
            note: note,
            amount: amount,
            currency: currency,
            expenseDate: dateString,
            category: category.rawValue,
            participantIds: participants.map { $0.id }
        )
    }
}
