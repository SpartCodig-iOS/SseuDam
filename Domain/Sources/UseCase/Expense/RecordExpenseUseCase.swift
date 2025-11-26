//
//  RecordExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/17/25.
//

import Foundation

public protocol RecordExpenseUseCaseProtocol {
    func execute(expense: Expense) async throws
}

public struct RecordExpenseUseCase: RecordExpenseUseCaseProtocol {
    private let repository: ExpenseRepositoryProtocol
    
    public init(repository: ExpenseRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(expense: Expense) async throws {
        try expense.validate()
        try await repository.save(expense: expense)
    }
}
