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
        if let date = date {
            let calendar = Calendar.current
            return Expense.mockList.filter { expense in
                calendar.isDate(expense.expenseDate, inSameDayAs: date)
            }
        } else {
            return Expense.mockList
        }
    }
}
