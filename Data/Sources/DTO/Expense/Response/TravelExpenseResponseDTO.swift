//
//  TravelExpenseResponseDTO.swift
//  Data
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import Domain

public struct ExpenseDTO: Codable {
    let id: String
    let title: String
    let amount: Double
    let currency: String
    let convertedAmount: Double
    let expenseDate: String
    let category: String
    let payer: MemberDTO
    let authorId: String
    let expenseMembers: [MemberDTO]

    func toDomain() -> Expense? {
        // yyyy-MM-dd 날짜 파싱 (서버에서 받은 날짜 그대로 사용)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        // Plain date는 timezone 변환하지 않음 (기본값 = TimeZone.current)

        guard let date = dateFormatter.date(from: expenseDate) else {
            return nil
        }

        // 카테고리 파싱 (없으면 .other)
        let expenseCategory = ExpenseCategory(rawValue: category) ?? .other

        // Participant 변환
        let members = expenseMembers.map { $0.toDomain() }

        return Expense(
            id: id,
            title: title,
            amount: amount,
            currency: currency,
            convertedAmount: convertedAmount,
            expenseDate: date,
            category: expenseCategory,
            payer: payer.toDomain(),
            participants: members
        )
    }
}
