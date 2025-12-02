//
//  ExpenseRepository.swift
//  Data
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import Domain

public final class ExpenseRepository: ExpenseRepositoryProtocol {
    
    private let remote: ExpenseRemoteDataSourceProtocol
    
    public init(remote: ExpenseRemoteDataSourceProtocol) {
        self.remote = remote
    }
    
    public func fetchTravelExpenses(
        travelId: String,
        page: Int,
        limit: Int
    ) async throws -> [Expense] {
        let responseDTO = try await remote.fetchTravelExpenses(
            travelId: travelId,
            page: page,
            limit: limit
        )
        
        return responseDTO.items.compactMap { $0.toDomain() }
    }
    
    public func save(travelId: String, expense: Expense) async throws {
        let requestDTO = expense.toCreateRequestDTO()
        try await remote.createExpense(travelId: travelId, body: requestDTO)
    }

    public func update(travelId: String, expense: Expense) async throws {
        let requestDTO = expense.toUpdateRequestDTO()
        try await remote.updateExpense(travelId: travelId, expenseId: expense.id, body: requestDTO)
    }

    public func delete(travelId: String, expenseId: String) async throws {
        try await remote.deleteExpense(travelId: travelId, expenseId: expenseId)
    }
}
