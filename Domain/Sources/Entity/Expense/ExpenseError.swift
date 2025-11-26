//
//  ExpenseError.swift
//  Domain
//
//  Created by 홍석현 on 11/25/25.
//

import Foundation

public enum ExpenseError: Error, Equatable {
    case invalidAmount(Double)      // 금액이 0 이하
    case invalidCurrency(String)    // 지원하지 않는 통화
    case invalidDate                // 날짜가 미래
    case emptyTitle                 // 제목이 비어있음
    case invalidParticipants        // 참가자 목록이 비어있음
    case payerNotInParticipants     // 지불자가 참가자 목록에 없음
}

extension ExpenseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidAmount(let amount):
            return "금액은 0보다 커야 합니다. (입력값: \(amount))"
        case .invalidCurrency(let currency):
            return "지원하지 않는 통화입니다: \(currency)"
        case .invalidDate:
            return "지출 날짜는 미래일 수 없습니다."
        case .emptyTitle:
            return "지출 제목을 입력해주세요."
        case .invalidParticipants:
            return "최소 1명 이상의 참가자가 필요합니다."
        case .payerNotInParticipants:
            return "지불자는 참가자 목록에 포함되어야 합니다."
        }
    }
}
