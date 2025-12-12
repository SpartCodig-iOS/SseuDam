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
    private let local: ExpenseLocalDataSourceProtocol
    
    public init(
        remote: ExpenseRemoteDataSourceProtocol,
        local: ExpenseLocalDataSourceProtocol
    ) {
        self.remote = remote
        self.local = local
    }
    
    public func fetchTravelExpenses(
        travelId: String
    ) -> AsyncStream<Result<[Expense], Error>> {
        AsyncStream { continuation in
            Task {
                // 1. 캐시 데이터
                if let cached = try? await local.loadCachedExpenses(travelId) {
                    let expense = cached.expenses.compactMap { $0.toDomain() }
                    continuation.yield(.success(expense))
                }
                
                // 2. 네트워크
                do {
                    let expensesDTO = try await remote.fetchTravelExpenses(
                        travelId: travelId
                    )
                    let expenses = expensesDTO.compactMap { $0.toDomain() }
                    
                    Task.detached { [weak self] in
                        let cache = ExpenseCache(
                            travelId: travelId,
                            expenses: expensesDTO
                        )
                        
                        try? await self?.local.saveCachedExpenses(cache)
                    }
                    continuation.yield(.success(expenses))
                } catch {
                    continuation.yield(.failure(error))
                }
                continuation.finish()
            }
        }
    }
    
    public func save(travelId: String, input: ExpenseInput) async throws {
        let requestDTO = CreateExpenseRequestDTO(
            title: input.title,
            amount: input.amount,
            currency: input.currency,
            expenseDate: input.formatExpenseDate(),
            payerId: input.payerId,
            category: input.category.rawValue,
            participantIds: input.participantIds
        )

        try await remote.createExpense(travelId: travelId, body: requestDTO)
    }

    public func update(travelId: String, expenseId: String, input: ExpenseInput) async throws {
        let requestDTO = UpdateExpenseRequestDTO(
            title: input.title,
            amount: input.amount,
            currency: input.currency,
            expenseDate: input.formatExpenseDate(),
            category: input.category.rawValue,
            payerId: input.payerId,
            participantIds: input.participantIds
        )
        try await remote.updateExpense(travelId: travelId, expenseId: expenseId, body: requestDTO)
    }

    public func delete(travelId: String, expenseId: String) async throws {
        try await remote.deleteExpense(travelId: travelId, expenseId: expenseId)
    }
}
