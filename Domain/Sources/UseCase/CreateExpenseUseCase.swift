//
//  CreateExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/30/25.
//

import Foundation
import Dependencies

public struct CreateExpenseUseCase {
    private let repository: ExpenseRepositoryProtocol

    public init(repository: ExpenseRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(travelId: String, input: CreateExpenseInput) async throws {
        let expense = Expense(
            id: UUID().uuidString,
            title: input.title,
            amount: input.amount,
            currency: input.currency,
            convertedAmount: input.convertedAmount,
            expenseDate: input.expenseDate,
            category: input.category,
            payerId: input.payerId,
            payerName: input.payerName,
            participants: input.participants
        )

        try expense.validate()
        try await repository.save(travelId: travelId, expense: expense)
    }
}

extension CreateExpenseUseCase: DependencyKey {
    public static var liveValue: CreateExpenseUseCase {
        @Dependency(\.expenseRepository) var repository
        return CreateExpenseUseCase(repository: repository)
    }

    public static var testValue: CreateExpenseUseCase {
        CreateExpenseUseCase(repository: MockExpenseRepository())
    }
}

extension DependencyValues {
    public var createExpenseUseCase: CreateExpenseUseCase {
        get { self[CreateExpenseUseCase.self] }
        set { self[CreateExpenseUseCase.self] = newValue }
    }
}
