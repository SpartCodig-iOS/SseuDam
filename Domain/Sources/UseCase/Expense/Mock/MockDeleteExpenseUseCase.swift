//
//  MockDeleteExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation

public struct MockDeleteExpenseUseCase: DeleteExpenseUseCaseProtocol {
    public init() {}

    public func execute(travelId: String, expenseId: String) async throws {
        // Mock implementation - 성공으로 간주
        print("Mock: Deleted expense \(expenseId) from travel \(travelId)")
    }
}
