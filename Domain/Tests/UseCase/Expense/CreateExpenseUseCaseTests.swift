//
//  CreateExpenseUseCaseTests.swift
//  Domain
//
//  Created by 홍석현 on 1/29/26.
//

import Testing
import Foundation
import Dependencies
@testable import Domain

@Suite("CreateExpenseUseCase Tests", .tags(.useCase, .expense))
struct CreateExpenseUseCaseTests {

    // MARK: - Test Data

    private let testTravelId = "travel-123"

    private var validInput: ExpenseInput {
        ExpenseInput(
            title: "점심 식사",
            amount: 50000.0,
            currency: "KRW",
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",
            participantIds: ["user1", "user2", "user3"]
        )
    }

    // MARK: - Happy Path

    @Test("TC-001: 유효한 입력으로 지출 생성 성공")
    func createExpense_withValidInput_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = CreateExpenseUseCase()
            let input = validInput

            // When
            try await useCase.execute(travelId: testTravelId, input: input)

            // Then
            let savedExpense = await mockRepository.fetch(id: "user1")
            #expect(savedExpense != nil)
        }
    }

    @Test("TC-002: 다양한 카테고리로 지출 생성 성공")
    func createExpense_withAllCategories_shouldSucceed() async throws {
        // Given
        let categories: [ExpenseCategory] = [
            .accommodation,
            .foodAndDrink,
            .transportation,
            .activity,
            .shopping,
            .other
        ]

        for category in categories {
            let mockRepository = MockExpenseRepository()

            try await withDependencies {
                $0.expenseRepository = mockRepository
            } operation: {
                let useCase = CreateExpenseUseCase()
                let input = ExpenseInput(
                    title: "테스트 지출",
                    amount: 10000.0,
                    currency: "KRW",
                    expenseDate: Date(),
                    category: category,
                    payerId: "user1",
                    participantIds: ["user1"]
                )

                // When / Then - 에러가 발생하지 않아야 함
                try await useCase.execute(travelId: testTravelId, input: input)
            }
        }
    }

    // MARK: - Edge Cases

    @Test("TC-003: 금액이 0.01인 경우 (최소 양수)")
    func createExpense_withMinimumAmount_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = CreateExpenseUseCase()
            let input = ExpenseInput(
                title: "최소 금액 테스트",
                amount: 0.01,
                currency: "KRW",
                expenseDate: Date(),
                category: .other,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            try await useCase.execute(travelId: testTravelId, input: input)
        }
    }

    @Test("TC-004: 참가자가 1명인 경우 (지불자 = 단일 참가자)")
    func createExpense_withSingleParticipant_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = CreateExpenseUseCase()
            let input = ExpenseInput(
                title: "1인 지출",
                amount: 10000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            try await useCase.execute(travelId: testTravelId, input: input)
            let savedExpense = await mockRepository.fetch(id: "user1")
            #expect(savedExpense != nil)
        }
    }

    @Test("TC-005: 금액이 매우 큰 경우")
    func createExpense_withLargeAmount_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = CreateExpenseUseCase()
            let input = ExpenseInput(
                title: "고가 지출",
                amount: 999_999_999.99,
                currency: "KRW",
                expenseDate: Date(),
                category: .accommodation,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            try await useCase.execute(travelId: testTravelId, input: input)
        }
    }

    @Test("TC-006: 제목에 특수문자 포함")
    func createExpense_withSpecialCharactersInTitle_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = CreateExpenseUseCase()
            let input = ExpenseInput(
                title: "점심 (맛집!) - 강남역 #맛집 @친구들",
                amount: 30000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            try await useCase.execute(travelId: testTravelId, input: input)
        }
    }

    @Test("TC-007: 참가자가 다수인 경우 (15명)")
    func createExpense_withManyParticipants_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()
        let participantIds = (1...15).map { "user\($0)" }

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = CreateExpenseUseCase()
            let input = ExpenseInput(
                title: "단체 회식",
                amount: 500000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: participantIds
            )

            // When / Then
            try await useCase.execute(travelId: testTravelId, input: input)
        }
    }

    // MARK: - Error Cases - Validation

    @Test("TC-008: 금액이 음수인 경우")
    func createExpense_withNegativeAmount_shouldThrowInvalidAmount() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = CreateExpenseUseCase()
            let input = ExpenseInput(
                title: "음수 금액 테스트",
                amount: -1000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            await #expect(throws: ExpenseError.invalidAmount(-1000.0)) {
                try await useCase.execute(travelId: testTravelId, input: input)
            }
        }
    }

    @Test("TC-009: 금액이 0인 경우")
    func createExpense_withZeroAmount_shouldThrowInvalidAmount() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = CreateExpenseUseCase()
            let input = ExpenseInput(
                title: "0원 테스트",
                amount: 0.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user1"]
            )

            // When / Then
            await #expect(throws: ExpenseError.invalidAmount(0.0)) {
                try await useCase.execute(travelId: testTravelId, input: input)
            }
        }
    }

    @Test("TC-010: 제목이 빈 문자열인 경우")
    func createExpense_withEmptyTitle_shouldThrowEmptyTitle() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = CreateExpenseUseCase()
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
                try await useCase.execute(travelId: testTravelId, input: input)
            }
        }
    }

    @Test("TC-011: 제목이 공백만 있는 경우")
    func createExpense_withWhitespaceOnlyTitle_shouldThrowEmptyTitle() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = CreateExpenseUseCase()
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
                try await useCase.execute(travelId: testTravelId, input: input)
            }
        }
    }

    @Test("TC-012: 참가자가 없는 경우 (빈 배열)")
    func createExpense_withEmptyParticipants_shouldThrowInvalidParticipants() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = CreateExpenseUseCase()
            let input = ExpenseInput(
                title: "참가자 없음 테스트",
                amount: 10000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: []
            )

            // When / Then
            await #expect(throws: ExpenseError.invalidParticipants) {
                try await useCase.execute(travelId: testTravelId, input: input)
            }
        }
    }

    @Test("TC-013: 지불자가 참가자 목록에 없는 경우")
    func createExpense_withPayerNotInParticipants_shouldThrowPayerNotInParticipants() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = CreateExpenseUseCase()
            let input = ExpenseInput(
                title: "지불자 미포함 테스트",
                amount: 10000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user2", "user3"]
            )

            // When / Then
            await #expect(throws: ExpenseError.payerNotInParticipants) {
                try await useCase.execute(travelId: testTravelId, input: input)
            }
        }
    }

    // MARK: - Error Cases - Repository

    @Test("TC-014: Repository 저장 실패 시")
    func createExpense_whenRepositoryFails_shouldThrowSaveFailedError() async throws {
        // Given
        let mockRepository = MockExpenseRepository()
        await mockRepository.setShouldFailSave(true, reason: "Network error")

        await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = CreateExpenseUseCase()
            let input = validInput

            // When / Then
            do {
                try await useCase.execute(travelId: testTravelId, input: input)
                Issue.record("Expected ExpenseRepositoryError.saveFailed to be thrown")
            } catch let error as ExpenseRepositoryError {
                switch error {
                case .saveFailed(let reason):
                    #expect(reason == "Network error")
                default:
                    Issue.record("Expected saveFailed error, got: \(error)")
                }
            } catch {
                Issue.record("Unexpected error type: \(error)")
            }
        }
    }
}
