//
//  FetchTravelExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import ComposableArchitecture

public protocol FetchTravelExpenseUseCaseProtocol {
    func execute(travelId: String, date: Date?) async throws -> [Expense]
}

public struct FetchTravelExpenseUseCase: FetchTravelExpenseUseCaseProtocol {
    private let repository: ExpenseRepositoryProtocol

    public init(repository: ExpenseRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(
        travelId: String,
        date: Date?
    ) async throws -> [Expense] {
        // TODO: 페이지네이션 처리 없이 전체 데이터를 가져오기 위해 큰 limit 사용
        // 추후 전체 조회 API가 있다면 교체 필요
        let allExpenses = try await repository.fetchTravelExpenses(
            travelId: travelId,
            page: 1,
            limit: 1000
        )
        
        if let date = date {
            let calendar = Calendar.current
            return allExpenses.filter { expense in
                calendar.isDate(expense.expenseDate, inSameDayAs: date)
            }
        } else {
            return allExpenses
        }
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
