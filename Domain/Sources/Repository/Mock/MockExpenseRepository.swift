//
//  MockExpenseRepository.swift
//  Domain
//
//  Created by 홍석현 on 11/25/25.
//

import Foundation

final public actor MockExpenseRepository: ExpenseRepositoryProtocol {
    private var storage: [String: Expense] = [:]
    private var shouldFailSave = false
    private var shouldFailUpdate = false
    private var saveErrorReason: String?
    
    public init() {}
    
    public func setShouldFailSave(
        _ value: Bool,
        reason: String? = nil
    ) {
        shouldFailSave = value
        saveErrorReason = reason
    }
    
    public func setShouldFailUpdate(_ value: Bool) {
        shouldFailUpdate = value
    }
    
    public func reset() {
        storage.removeAll()
        shouldFailSave = false
        shouldFailUpdate = false
        saveErrorReason = nil
    }
    
    public func fetchTravelExpenses(
        travelId: String,
        page: Int,
        limit: Int
    ) async throws -> [Expense] {
        return Expense.mockList
    }
    
    public func save(
        travelId: String,
        expense: Expense
    ) async throws {
        if shouldFailSave {
            let reason = saveErrorReason ?? "Unknown error"
            throw ExpenseRepositoryError.saveFailed(reason: reason)
        }
        
        storage[expense.id] = expense
    }
    
    public func update(
        travelId: String,
        expense: Expense
    ) async throws {
        if shouldFailUpdate {
            throw ExpenseRepositoryError.updateFailed(reason: "업데이트 실패")
        }
        
        storage[expense.id] = expense
    }
    
    // MARK: - Test Helpers
    
    public func fetch(id: String) -> Expense? {
        storage[id]
    }
    
    public func fetchAll() -> [Expense] {
        Array(storage.values)
    }
}
