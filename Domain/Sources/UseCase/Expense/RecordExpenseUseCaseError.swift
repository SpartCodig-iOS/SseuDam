//
//  RecordExpenseUseCaseError.swift
//  Domain
//
//  Created by 홍석현 on 11/26/25.
//

import Foundation

public enum RecordExpenseUseCaseError: Error {
    case validationFailed(ExpenseError)     // 비즈니스 검증 실패
    case saveFailed(String)                 // 저장 실패 (서버/네트워크)
    case unknown(Error)                     // 예상치 못한 에러
}

extension RecordExpenseUseCaseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .validationFailed(let expenseError):
            return expenseError.localizedDescription
        case .saveFailed(let reason):
            return "지출 기록에 실패했습니다: \(reason)"
        case .unknown(let error):
            return "알 수 없는 오류가 발생했습니다: \(error.localizedDescription)"
        }
    }
}
