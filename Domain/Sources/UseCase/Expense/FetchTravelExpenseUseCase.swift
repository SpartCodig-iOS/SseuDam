//
//  FetchTravelExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import ComposableArchitecture

public protocol FetchTravelExpenseUseCaseProtocol {
    func execute(travelId: String, page: Int, limit: Int) async throws -> [Expense]
}

public struct FetchTravelExpenseUseCase: FetchTravelExpenseUseCaseProtocol {
    private let repository: ExpenseRepositoryProtocol

    public init(repository: ExpenseRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(
        travelId: String,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> [Expense] {
        return try await repository.fetchTravelExpenses(
            travelId: travelId,
            page: page,
            limit: limit
        )
    }
}

// MARK: - DependencyKey
public enum FetchTravelExpenseUseCaseDependencyKey: DependencyKey {
    public static var liveValue: any FetchTravelExpenseUseCaseProtocol = MockFetchTravelExpenseUseCase()

    public static var testValue: any FetchTravelExpenseUseCaseProtocol = MockFetchTravelExpenseUseCase()

    public static var previewValue: any FetchTravelExpenseUseCaseProtocol = MockFetchTravelExpenseUseCase()
}

public extension DependencyValues {
    var fetchTravelExpenseUseCase: any FetchTravelExpenseUseCaseProtocol {
        get { self[FetchTravelExpenseUseCaseDependencyKey.self] }
        set { self[FetchTravelExpenseUseCaseDependencyKey.self] = newValue }
    }
}
