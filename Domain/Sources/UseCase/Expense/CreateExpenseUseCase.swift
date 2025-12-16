//
//  CreateExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/30/25.
//

import Foundation
import Dependencies

public protocol CreateExpenseUseCaseProtocol {
    func execute(travelId: String, input: ExpenseInput) async throws
}

public struct CreateExpenseUseCase: CreateExpenseUseCaseProtocol {
    @Dependency(\.expenseRepository) private var repository: ExpenseRepositoryProtocol
    
    public func execute(travelId: String, input: ExpenseInput) async throws {
        try input.validate()
        try await repository.save(travelId: travelId, input: input)
    }
}

public enum CreateExpenseUseCaseDependencyKey: DependencyKey {
    public static var liveValue: CreateExpenseUseCaseProtocol = CreateExpenseUseCase()

    public static var testValue: CreateExpenseUseCaseProtocol = CreateExpenseUseCase()
}

extension DependencyValues {
    public var createExpenseUseCase: CreateExpenseUseCaseProtocol {
        get { self[CreateExpenseUseCaseDependencyKey.self] }
        set { self[CreateExpenseUseCaseDependencyKey.self] = newValue }
    }
}
