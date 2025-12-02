//
//  MockUpdateExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation

public struct MockUpdateExpenseUseCase: UpdateExpenseUseCaseProtocol {
    public init() {}

    public func execute(travelId: String, expense: Expense) async throws {
        // Mock implementation - 성공으로 간주
        print("Mock: Updated expense \(expense.id) for travel \(travelId)")
    }
}
