//
//  MockFetchTravelExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation

public struct MockFetchTravelExpenseUseCase: FetchTravelExpenseUseCaseProtocol {
    public init() {}

    public func execute(travelId: String, date: Date?) async throws -> [Expense] {
        return Expense.mockList
    }
}
