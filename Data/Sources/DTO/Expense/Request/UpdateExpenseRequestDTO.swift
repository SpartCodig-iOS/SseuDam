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
        // yyyy-MM-dd 형식으로 날짜 변환 (사용자가 선택한 날짜 그대로 전송)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        // Plain date는 timezone 변환하지 않음 (기본값 = TimeZone.current)
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
