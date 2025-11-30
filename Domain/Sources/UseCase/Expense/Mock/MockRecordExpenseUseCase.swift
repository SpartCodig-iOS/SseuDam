//
//  MockRecordExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation

public struct MockRecordExpenseUseCase: RecordExpenseUseCaseProtocol {
    public init() {}

    public func execute(travelId: String, expense: Expense) async throws {
        // Mock implementation - do nothing
        print("Mock: Recording expense - \(expense.title) for travel: \(travelId)")
    }
}
