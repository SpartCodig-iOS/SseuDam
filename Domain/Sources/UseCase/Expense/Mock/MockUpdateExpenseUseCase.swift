//
//  MockUpdateExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation

public struct MockUpdateExpenseUseCase: UpdateExpenseUseCaseProtocol {

    public init() {}

    public func execute(travelId: String, expenseId: String, input: ExpenseInput) async throws {
        print("Mock: Updated expense \(expenseId) for travel \(travelId)")
    }
}
