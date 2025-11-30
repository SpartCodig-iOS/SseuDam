//
//  RecordExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/17/25.
//

import Foundation
import ComposableArchitecture

public protocol RecordExpenseUseCaseProtocol {
    func execute(travelId: String, expense: Expense) async throws
}

public struct RecordExpenseUseCase: RecordExpenseUseCaseProtocol {
    private let repository: ExpenseRepositoryProtocol

    public init(repository: ExpenseRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(travelId: String, expense: Expense) async throws {
        try expense.validate()
        try await repository.save(travelId: travelId, expense: expense)
    }
}

// MARK: - DependencyKey
public enum RecordExpenseUseCaseDependencyKey: DependencyKey {
    public static var liveValue: any RecordExpenseUseCaseProtocol = MockRecordExpenseUseCase()

    public static var testValue: any RecordExpenseUseCaseProtocol = MockRecordExpenseUseCase()

    public static var previewValue: any RecordExpenseUseCaseProtocol = MockRecordExpenseUseCase()
}

public extension DependencyValues {
    var recordExpenseUseCase: any RecordExpenseUseCaseProtocol {
        get { self[RecordExpenseUseCaseDependencyKey.self] }
        set { self[RecordExpenseUseCaseDependencyKey.self] = newValue }
    }
}
