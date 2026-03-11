//
//  UpdateExpenseUseCaseTests.swift
//  Domain
//
//  Created by 홍석현 on 1/29/26.
//

import Testing
import Foundation
import Dependencies
@testable import Domain

@Suite("UpdateExpenseUseCase Tests", .tags(.useCase, .expense))
struct UpdateExpenseUseCaseTests {

    // MARK: - Test Data

    private let testTravelId = "travel-123"
    private let testExpenseId = "expense-456"

    private var validInput: ExpenseInput {
        ExpenseInput(
            title: "수정된 지출",
            amount: 75000.0,
            currency: "KRW",
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",
            participantIds: ["user1", "user2", "user3"]
        )
    }

    // MARK: - Happy Path

    @Test("TC-026: 지출 정보 수정 성공")
    func updateExpense_withValidInput_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = validInput

            // When
            try await useCase.execute(
                travelId: testTravelId,
                expenseId: testExpenseId,
                input: input
            )

            // Then - 에러 없이 완료되면 성공
            let updatedExpense = await mockRepository.fetch(id: testExpenseId)
            #expect(updatedExpense != nil)
        }
    }

    @Test("TC-027: 제목만 수정")
    func updateExpense_withOnlyTitleChanged_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = ExpenseInput(
                title: "새로운 제목",
                amount: 50000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            try await useCase.execute(
                travelId: testTravelId,
                expenseId: testExpenseId,
                input: input
            )
        }
    }

    @Test("TC-028: 금액만 수정")
    func updateExpense_withOnlyAmountChanged_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = ExpenseInput(
                title: "기존 제목",
                amount: 99999.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            try await useCase.execute(
                travelId: testTravelId,
                expenseId: testExpenseId,
                input: input
            )
        }
    }

    @Test("TC-029: 참가자 변경")
    func updateExpense_withParticipantsChanged_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = ExpenseInput(
                title: "참가자 변경 테스트",
                amount: 30000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user1", "user4", "user5"]
            )

            // When / Then
            try await useCase.execute(
                travelId: testTravelId,
                expenseId: testExpenseId,
                input: input
            )
        }
    }

    @Test("TC-030: 지불자 변경 (새 지불자가 참가자에 포함)")
    func updateExpense_withPayerChanged_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = ExpenseInput(
                title: "지불자 변경 테스트",
                amount: 40000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user2",
                participantIds: ["user1", "user2", "user3"]
            )

            // When / Then
            try await useCase.execute(
                travelId: testTravelId,
                expenseId: testExpenseId,
                input: input
            )
        }
    }

    // MARK: - Edge Cases

    @Test("TC-031: 동일한 값으로 수정 (변경 없음)")
    func updateExpense_withSameValues_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = ExpenseInput(
                title: "동일 값 테스트",
                amount: 50000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When - 동일한 값으로 두 번 수정
            try await useCase.execute(
                travelId: testTravelId,
                expenseId: testExpenseId,
                input: input
            )
            try await useCase.execute(
                travelId: testTravelId,
                expenseId: testExpenseId,
                input: input
            )

            // Then - 멱등성 보장
        }
    }

    @Test("카테고리 변경")
    func updateExpense_withCategoryChanged_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = ExpenseInput(
                title: "카테고리 변경 테스트",
                amount: 100000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .accommodation,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            try await useCase.execute(
                travelId: testTravelId,
                expenseId: testExpenseId,
                input: input
            )
        }
    }

    @Test("통화 변경")
    func updateExpense_withCurrencyChanged_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = ExpenseInput(
                title: "통화 변경 테스트",
                amount: 100.0,
                currency: "USD",
                expenseDate: Date(),
                category: .shopping,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            try await useCase.execute(
                travelId: testTravelId,
                expenseId: testExpenseId,
                input: input
            )
        }
    }

    @Test("날짜 변경")
    func updateExpense_withDateChanged_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = ExpenseInput(
                title: "날짜 변경 테스트",
                amount: 20000.0,
                currency: "KRW",
                expenseDate: yesterday,
                category: .transportation,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            try await useCase.execute(
                travelId: testTravelId,
                expenseId: testExpenseId,
                input: input
            )
        }
    }

    // MARK: - Error Cases - Validation

    @Test("TC-032: 수정 시 금액을 음수로 변경")
    func updateExpense_withNegativeAmount_shouldThrowInvalidAmount() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = ExpenseInput(
                title: "음수 금액 수정 테스트",
                amount: -5000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            await #expect(throws: ExpenseError.invalidAmount(-5000.0)) {
                try await useCase.execute(
                    travelId: testTravelId,
                    expenseId: testExpenseId,
                    input: input
                )
            }
        }
    }

    @Test("TC-033: 수정 시 제목을 빈 문자열로 변경")
    func updateExpense_withEmptyTitle_shouldThrowEmptyTitle() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = ExpenseInput(
                title: "",
                amount: 10000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            await #expect(throws: ExpenseError.emptyTitle) {
                try await useCase.execute(
                    travelId: testTravelId,
                    expenseId: testExpenseId,
                    input: input
                )
            }
        }
    }

    @Test("TC-034: 수정 시 참가자를 빈 배열로 변경")
    func updateExpense_withEmptyParticipants_shouldThrowInvalidParticipants() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = ExpenseInput(
                title: "참가자 없음 수정 테스트",
                amount: 10000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: []
            )

            // When / Then
            await #expect(throws: ExpenseError.invalidParticipants) {
                try await useCase.execute(
                    travelId: testTravelId,
                    expenseId: testExpenseId,
                    input: input
                )
            }
        }
    }

    @Test("TC-035: 수정 시 지불자를 참가자에서 제외")
    func updateExpense_withPayerNotInParticipants_shouldThrowPayerNotInParticipants() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = ExpenseInput(
                title: "지불자 미포함 수정 테스트",
                amount: 10000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user2", "user3"]
            )

            // When / Then
            await #expect(throws: ExpenseError.payerNotInParticipants) {
                try await useCase.execute(
                    travelId: testTravelId,
                    expenseId: testExpenseId,
                    input: input
                )
            }
        }
    }

    @Test("수정 시 금액을 0으로 변경")
    func updateExpense_withZeroAmount_shouldThrowInvalidAmount() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = ExpenseInput(
                title: "0원 수정 테스트",
                amount: 0.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            await #expect(throws: ExpenseError.invalidAmount(0.0)) {
                try await useCase.execute(
                    travelId: testTravelId,
                    expenseId: testExpenseId,
                    input: input
                )
            }
        }
    }

    @Test("수정 시 제목을 공백만으로 변경")
    func updateExpense_withWhitespaceOnlyTitle_shouldThrowEmptyTitle() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = ExpenseInput(
                title: "   ",
                amount: 10000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            await #expect(throws: ExpenseError.emptyTitle) {
                try await useCase.execute(
                    travelId: testTravelId,
                    expenseId: testExpenseId,
                    input: input
                )
            }
        }
    }

    // MARK: - Error Cases - Repository

    @Test("TC-036: Repository 수정 실패 시")
    func updateExpense_whenRepositoryFails_shouldThrowUpdateFailedError() async throws {
        // Given
        let mockRepository = MockExpenseRepository()
        await mockRepository.setShouldFailUpdate(true)

        await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = UpdateExpenseUseCase()
            let input = validInput

            // When / Then
            do {
                try await useCase.execute(
                    travelId: testTravelId,
                    expenseId: testExpenseId,
                    input: input
                )
                Issue.record("Expected ExpenseRepositoryError.updateFailed to be thrown")
            } catch let error as ExpenseRepositoryError {
                switch error {
                case .updateFailed:
                    // Expected
                    break
                default:
                    Issue.record("Expected updateFailed error, got: \(error)")
                }
            } catch {
                Issue.record("Unexpected error type: \(error)")
            }
        }
    }
}
