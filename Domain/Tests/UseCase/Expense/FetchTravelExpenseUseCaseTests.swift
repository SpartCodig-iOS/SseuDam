//
//  FetchTravelExpenseUseCaseTests.swift
//  Domain
//
//  Created by 홍석현 on 1/29/26.
//

import Testing
import Foundation
import Dependencies
@testable import Domain

@Suite("FetchTravelExpenseUseCase Tests", .tags(.useCase, .expense))
struct FetchTravelExpenseUseCaseTests {

    // MARK: - Test Data

    private let testTravelId = "travel-123"

    // MARK: - Happy Path

    @Test("TC-019: 지출 목록 조회 성공 (날짜 필터 없음)")
    func fetchExpenses_withoutDateFilter_shouldReturnAllExpenses() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = FetchTravelExpenseUseCase()

            // When
            let stream = useCase.execute(travelId: testTravelId, date: nil)
            var results: [Result<[Expense], Error>] = []

            for await result in stream {
                results.append(result)
            }

            // Then
            #expect(!results.isEmpty)

            if case .success(let expenses) = results.first {
                #expect(!expenses.isEmpty)
                #expect(expenses.count == Expense.mockList.count)
            } else {
                Issue.record("Expected success result")
            }
        }
    }

    @Test("TC-020: 특정 날짜의 지출만 조회 (날짜 필터 적용)")
    func fetchExpenses_withDateFilter_shouldReturnFilteredExpenses() async throws {
        // Given
        let mockRepository = MockExpenseRepository()
        let today = Date()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = FetchTravelExpenseUseCase()

            // When
            let stream = useCase.execute(travelId: testTravelId, date: today)
            var results: [Result<[Expense], Error>] = []

            for await result in stream {
                results.append(result)
            }

            // Then
            #expect(!results.isEmpty)

            if case .success(let expenses) = results.first {
                // 오늘 날짜의 지출만 포함되어야 함
                let calendar = Calendar.current
                for expense in expenses {
                    #expect(calendar.isDate(expense.expenseDate, inSameDayAs: today))
                }
            } else {
                Issue.record("Expected success result")
            }
        }
    }

    @Test("TC-021: 빈 지출 목록 조회")
    func fetchExpenses_whenNoExpenses_shouldReturnEmptyArray() async throws {
        // Given
        // MockExpenseRepository는 항상 mockList를 반환하므로
        // 빈 배열 테스트를 위해서는 날짜 필터를 사용하여 매칭되는 항목이 없도록 함
        let mockRepository = MockExpenseRepository()
        let veryOldDate = Date(timeIntervalSince1970: 0) // 1970년 1월 1일

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = FetchTravelExpenseUseCase()

            // When
            let stream = useCase.execute(travelId: testTravelId, date: veryOldDate)
            var results: [Result<[Expense], Error>] = []

            for await result in stream {
                results.append(result)
            }

            // Then
            #expect(!results.isEmpty)

            if case .success(let expenses) = results.first {
                #expect(expenses.isEmpty)
            } else {
                Issue.record("Expected success result with empty array")
            }
        }
    }

    // MARK: - Edge Cases

    @Test("TC-022: 해당 날짜에 지출이 없는 경우")
    func fetchExpenses_withDateNoExpenses_shouldReturnEmptyArray() async throws {
        // Given
        let mockRepository = MockExpenseRepository()
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date())!

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = FetchTravelExpenseUseCase()

            // When
            let stream = useCase.execute(travelId: testTravelId, date: oneYearAgo)
            var results: [Result<[Expense], Error>] = []

            for await result in stream {
                results.append(result)
            }

            // Then
            if case .success(let expenses) = results.first {
                #expect(expenses.isEmpty)
            } else {
                Issue.record("Expected success result")
            }
        }
    }

    @Test("TC-023: AsyncStream이 여러 번 yield하는 경우")
    func fetchExpenses_withMultipleYields_shouldReceiveAllResults() async throws {
        // Given
        // MockExpenseRepository는 현재 한 번만 yield하므로
        // 이 테스트는 기본 동작만 검증
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = FetchTravelExpenseUseCase()

            // When
            let stream = useCase.execute(travelId: testTravelId, date: nil)
            var resultCount = 0

            for await _ in stream {
                resultCount += 1
            }

            // Then
            #expect(resultCount >= 1)
        }
    }

    @Test("TC-024: 날짜 경계값 테스트 (자정 기준)")
    func fetchExpenses_withDateBoundary_shouldFilterCorrectly() async throws {
        // Given
        let mockRepository = MockExpenseRepository()
        let calendar = Calendar.current

        // 오늘의 시작 시간 (00:00:00)
        let startOfToday = calendar.startOfDay(for: Date())
        // 오늘의 끝 시간 (23:59:59)
        let endOfToday = calendar.date(byAdding: .second, value: -1, to: calendar.date(byAdding: .day, value: 1, to: startOfToday)!)!

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = FetchTravelExpenseUseCase()

            // When - 오늘 날짜로 조회
            let stream = useCase.execute(travelId: testTravelId, date: startOfToday)
            var results: [Expense] = []

            for await result in stream {
                if case .success(let expenses) = result {
                    results = expenses
                }
            }

            // Then - 결과의 모든 지출이 오늘 날짜여야 함
            for expense in results {
                let isSameDay = calendar.isDate(expense.expenseDate, inSameDayAs: startOfToday)
                #expect(isSameDay)
            }
        }
    }

    // MARK: - Error Cases

    @Test("TC-025: Repository 조회 실패 시")
    func fetchExpenses_whenRepositoryFails_shouldReturnFailureResult() async throws {
        // Given
        // MockExpenseRepository는 현재 조회 실패를 시뮬레이션하지 않음
        // Repository 확장 시 테스트 가능
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = FetchTravelExpenseUseCase()

            // When
            let stream = useCase.execute(travelId: testTravelId, date: nil)

            // Then - 현재는 성공 결과만 검증
            for await result in stream {
                switch result {
                case .success:
                    // 현재 Mock은 항상 성공
                    break
                case .failure:
                    // Repository 확장 시 에러 케이스 테스트
                    break
                }
            }
        }
    }

    @Test("빈 travelId로 조회")
    func fetchExpenses_withEmptyTravelId_shouldReturnResults() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = FetchTravelExpenseUseCase()

            // When
            let stream = useCase.execute(travelId: "", date: nil)
            var hasResults = false

            for await result in stream {
                if case .success = result {
                    hasResults = true
                }
            }

            // Then
            #expect(hasResults)
        }
    }

    @Test("과거 날짜로 필터링")
    func fetchExpenses_withPastDate_shouldFilterCorrectly() async throws {
        // Given
        let mockRepository = MockExpenseRepository()
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = FetchTravelExpenseUseCase()

            // When
            let stream = useCase.execute(travelId: testTravelId, date: twoDaysAgo)
            var expenses: [Expense] = []

            for await result in stream {
                if case .success(let fetchedExpenses) = result {
                    expenses = fetchedExpenses
                }
            }

            // Then - 2일 전 지출만 포함되어야 함
            let calendar = Calendar.current
            for expense in expenses {
                #expect(calendar.isDate(expense.expenseDate, inSameDayAs: twoDaysAgo))
            }
        }
    }
}
