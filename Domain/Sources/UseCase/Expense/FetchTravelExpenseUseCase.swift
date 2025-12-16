//
//  FetchTravelExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import ComposableArchitecture

public protocol FetchTravelExpenseUseCaseProtocol {
    func execute(travelId: String, date: Date?) -> AsyncStream<Result<[Expense], Error>>
}

public struct FetchTravelExpenseUseCase: FetchTravelExpenseUseCaseProtocol {
    @Dependency(\.expenseRepository) private var repository: ExpenseRepositoryProtocol

    public func execute(
        travelId: String,
        date: Date?
    ) -> AsyncStream<Result<[Expense], Error>> {
        AsyncStream { continuation in
            Task {
                for await result in repository.fetchTravelExpenses(
                    travelId: travelId
                ) {
                    // 날짜 필터링 적용
                    let filteredResult = result.map { expenses in
                        filterExpenses(expenses, by: date)
                    }
                    
                    continuation.yield(filteredResult)
                }
                
                continuation.finish()
            }
        }
    }
    
    // 헬퍼 메서드
    private func filterExpenses(_ expenses: [Expense], by date: Date?) -> [Expense] {
        guard let date = date else { return expenses }
        
        let calendar = Calendar.current
        return expenses.filter { expense in
            calendar.isDate(expense.expenseDate, inSameDayAs: date)
        }
    }
}

// MARK: - DependencyKey
public enum FetchTravelExpenseUseCaseDependencyKey: DependencyKey {
    public static var liveValue: any FetchTravelExpenseUseCaseProtocol = FetchTravelExpenseUseCase()

    public static var testValue: any FetchTravelExpenseUseCaseProtocol = MockFetchTravelExpenseUseCase()

    public static var previewValue: any FetchTravelExpenseUseCaseProtocol = MockFetchTravelExpenseUseCase()
}

public extension DependencyValues {
    var fetchTravelExpenseUseCase: any FetchTravelExpenseUseCaseProtocol {
        get { self[FetchTravelExpenseUseCaseDependencyKey.self] }
        set { self[FetchTravelExpenseUseCaseDependencyKey.self] = newValue }
    }
}
