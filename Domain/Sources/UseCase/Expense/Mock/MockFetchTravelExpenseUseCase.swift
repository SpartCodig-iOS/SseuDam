//
//  MockFetchTravelExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation

public struct MockFetchTravelExpenseUseCase: FetchTravelExpenseUseCaseProtocol {
    public init() {}

    public func execute(travelId: String, date: Date?) -> AsyncStream<Result<[Expense], any Error>> {
        AsyncStream { continuation in
            // Mock 데이터를 즉시 emit
            continuation.yield(.success(Expense.mockList))
            continuation.finish()
        }
    }
}
