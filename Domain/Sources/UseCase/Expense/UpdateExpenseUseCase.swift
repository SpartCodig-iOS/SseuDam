//
//  UpdateExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import ComposableArchitecture

public protocol UpdateExpenseUseCaseProtocol {
    func execute(travelId: String, expenseId: String, input: ExpenseInput) async throws
}

public struct UpdateExpenseUseCase: UpdateExpenseUseCaseProtocol {
    @Dependency(\.expenseRepository) private var repository: ExpenseRepositoryProtocol

    public func execute(travelId: String, expenseId: String, input: ExpenseInput) async throws {
        try input.validate()
        try await repository.update(travelId: travelId, expenseId: expenseId, input: input)
    }
}

// MARK: - DependencyKey
public enum UpdateExpenseUseCaseDependencyKey: DependencyKey {
    public static var liveValue: any UpdateExpenseUseCaseProtocol = UpdateExpenseUseCase()

    public static var testValue: any UpdateExpenseUseCaseProtocol = MockUpdateExpenseUseCase()

    public static var previewValue: any UpdateExpenseUseCaseProtocol = MockUpdateExpenseUseCase()
}

public extension DependencyValues {
    var updateExpenseUseCase: any UpdateExpenseUseCaseProtocol {
        get { self[UpdateExpenseUseCaseDependencyKey.self] }
        set { self[UpdateExpenseUseCaseDependencyKey.self] = newValue }
    }
}
