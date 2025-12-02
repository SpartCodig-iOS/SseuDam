//
//  UpdateExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import ComposableArchitecture

public protocol UpdateExpenseUseCaseProtocol {
    func execute(travelId: String, expense: Expense) async throws
}

public struct UpdateExpenseUseCase: UpdateExpenseUseCaseProtocol {
    private let repository: ExpenseRepositoryProtocol

    public init(repository: ExpenseRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(travelId: String, expense: Expense) async throws {
        try expense.validate()
        try await repository.update(travelId: travelId, expense: expense)
    }
}

// MARK: - DependencyKey
public enum UpdateExpenseUseCaseDependencyKey: DependencyKey {
    public static var liveValue: any UpdateExpenseUseCaseProtocol = MockUpdateExpenseUseCase()

    public static var testValue: any UpdateExpenseUseCaseProtocol = MockUpdateExpenseUseCase()

    public static var previewValue: any UpdateExpenseUseCaseProtocol = MockUpdateExpenseUseCase()
}

public extension DependencyValues {
    var updateExpenseUseCase: any UpdateExpenseUseCaseProtocol {
        get { self[UpdateExpenseUseCaseDependencyKey.self] }
        set { self[UpdateExpenseUseCaseDependencyKey.self] = newValue }
    }
}
