//
//  DeleteExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import ComposableArchitecture

public protocol DeleteExpenseUseCaseProtocol {
    func execute(travelId: String, expenseId: String) async throws
}

public struct DeleteExpenseUseCase: DeleteExpenseUseCaseProtocol {
    private let repository: ExpenseRepositoryProtocol

    public init(repository: ExpenseRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(travelId: String, expenseId: String) async throws {
        try await repository.delete(travelId: travelId, expenseId: expenseId)
    }
}

// MARK: - DependencyKey
public enum DeleteExpenseUseCaseDependencyKey: DependencyKey {
    public static var liveValue: any DeleteExpenseUseCaseProtocol = MockDeleteExpenseUseCase()

    public static var testValue: any DeleteExpenseUseCaseProtocol = MockDeleteExpenseUseCase()

    public static var previewValue: any DeleteExpenseUseCaseProtocol = MockDeleteExpenseUseCase()
}

public extension DependencyValues {
    var deleteExpenseUseCase: any DeleteExpenseUseCaseProtocol {
        get { self[DeleteExpenseUseCaseDependencyKey.self] }
        set { self[DeleteExpenseUseCaseDependencyKey.self] = newValue }
    }
}
