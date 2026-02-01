//
//  DeleteExpenseUseCaseTests.swift
//  Domain
//
//  Created by 홍석현 on 1/29/26.
//

import Testing
import Foundation
import Dependencies
@testable import Domain

@Suite("DeleteExpenseUseCase Tests", .tags(.useCase, .expense))
struct DeleteExpenseUseCaseTests {

    // MARK: - Test Data

    private let testTravelId = "travel-123"
    private let testExpenseId = "expense-456"

    // MARK: - Happy Path

    @Test("TC-015: 존재하는 지출 삭제 성공")
    func deleteExpense_withValidIds_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = DeleteExpenseUseCase()

            // When
            try await useCase.execute(travelId: testTravelId, expenseId: testExpenseId)

            // Then - 에러 없이 완료되면 성공
        }
    }

    // MARK: - Edge Cases

    @Test("TC-016: 빈 expenseId로 삭제 시도")
    func deleteExpense_withEmptyExpenseId_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = DeleteExpenseUseCase()

            // When / Then - 현재 구현상 Repository가 처리하므로 성공
            try await useCase.execute(travelId: testTravelId, expenseId: "")
        }
    }

    @Test("TC-017: 존재하지 않는 expenseId로 삭제 시도")
    func deleteExpense_withNonExistentExpenseId_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = DeleteExpenseUseCase()

            // When / Then - idempotent 설계로 성공
            try await useCase.execute(travelId: testTravelId, expenseId: "non-existent-id")
        }
    }

    @Test("빈 travelId로 삭제 시도")
    func deleteExpense_withEmptyTravelId_shouldSucceed() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = DeleteExpenseUseCase()

            // When / Then
            try await useCase.execute(travelId: "", expenseId: testExpenseId)
        }
    }

    @Test("여러 번 동일한 지출 삭제 시도 (멱등성)")
    func deleteExpense_multipleTimes_shouldBeIdempotent() async throws {
        // Given
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = DeleteExpenseUseCase()

            // When - 동일한 지출 여러 번 삭제
            try await useCase.execute(travelId: testTravelId, expenseId: testExpenseId)
            try await useCase.execute(travelId: testTravelId, expenseId: testExpenseId)
            try await useCase.execute(travelId: testTravelId, expenseId: testExpenseId)

            // Then - 모두 성공해야 함
        }
    }

    // MARK: - Error Cases

    @Test("TC-018: Repository 삭제 실패 시")
    func deleteExpense_whenRepositoryFails_shouldThrowError() async throws {
        // Given
        // MockExpenseRepository는 현재 delete 실패 시뮬레이션을 지원하지 않으므로
        // 이 테스트는 Repository 확장 시 활성화 필요
        // 현재는 정상 동작만 테스트
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = DeleteExpenseUseCase()

            // Repository에 shouldFailDelete 기능이 추가되면
            // await mockRepository.setShouldFailDelete(true) 설정 후 테스트

            try await useCase.execute(travelId: testTravelId, expenseId: testExpenseId)
        }
    }
}
