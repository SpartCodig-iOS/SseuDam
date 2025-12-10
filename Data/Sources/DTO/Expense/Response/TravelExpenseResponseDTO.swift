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
        let amount: Double
        let currency: String
        let convertedAmount: Double
        let expenseDate: String
        let category: String
        let payerId: String
        let payerName: String
        let authorId: String
        let participants: [ParticipantDTO]

        struct ParticipantDTO: Decodable {
            let memberId: String
            let name: String

            func toDomain() -> TravelMember {
                TravelMember(
                    id: memberId,
                    name: name,
                    role: .member
                )
            }
        }

        func toDomain() -> Expense? {
            // yyyy-MM-dd 날짜 파싱
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            guard let date = dateFormatter.date(from: expenseDate) else {
                return nil
            }

            // 카테고리 파싱 (없으면 .other)
            let expenseCategory = ExpenseCategory(rawValue: category) ?? .other

            // Participant 변환
            let members = participants.map { $0.toDomain() }

            return Expense(
                id: id,
                title: title,
                amount: amount,
                currency: currency,
                convertedAmount: convertedAmount,
                expenseDate: date,
                category: expenseCategory,
                payerId: payerId,
                payerName: payerName,
                participants: members
            )
        }
    }
}
