//
//  ExpenseRepositoryError.swift
//  Domain
//
//  Created by 홍석현 on 11/26/25.
//

import Foundation

public enum ExpenseRepositoryError: Error {
    case saveFailed(reason: String)
    case updateFailed(reason: String)
}

extension ExpenseRepositoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .saveFailed(let reason):
            return "저장에 실패했습니다: \(reason)"
        case .updateFailed(let reason):
            return "수정에 실패했습니다: \(reason)"
        }
    }
}
