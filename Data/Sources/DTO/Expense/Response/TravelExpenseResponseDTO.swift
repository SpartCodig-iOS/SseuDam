//
//  TravelExpenseResponseDTO.swift
//  Data
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import Domain

public struct TravelExpenseResponseDTO: Decodable {
    let total: Int
    let page: Int
    let limit: Int
    let items: [ExpenseDTO]

    struct ExpenseDTO: Decodable {
        let id: String
        let title: String
        let note: String
        let amount: Double
        let currency: String // JPY
        let expenseDate: String
        let category: String?
        let autherId: String
        let payerId: String
        let payerName: String
        let participants: [TravelMemberDTO]

        func toDomain() -> Expense? {
            // ISO8601 날짜 파싱
            let dateFormatter = ISO8601DateFormatter()
            guard let date = dateFormatter.date(from: expenseDate) else {
                return nil
            }

            // 카테고리 파싱 (없으면 .other)
            let expenseCategory: ExpenseCategory
            if let categoryString = category,
               let parsedCategory = ExpenseCategory(rawValue: categoryString) {
                expenseCategory = parsedCategory
            } else {
                expenseCategory = .other
            }

            // TravelMember 변환
            let members = participants.map { $0.toDomain() }

            return Expense(
                id: id,
                title: title,
                note: note.isEmpty ? nil : note,
                amount: amount,
                currency: currency,
                convertedAmount: amount, // TODO: 실제 환율 계산 필요
                expenseDate: date,
                category: expenseCategory,
                payerId: payerId,
                payerName: payerName,
                participants: members
            )
        }
    }
}
