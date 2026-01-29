//
//  FetchSettlementUseCaseTests.swift
//  Domain
//
//  Created by 홍석현 on 1/29/26.
//

import Testing
import Dependencies
@testable import Domain

@Suite("정산 조회 UseCase 테스트", .tags(.useCase, .settlement))
struct FetchSettlementUseCaseTests {

    // MARK: - Happy Path

    /// TC-FETCH-001: 유효한 travelId로 정산 조회 성공
    @Test("유효한 travelId로 정산 조회 성공")
    func fetchSettlement_withValidTravelId_returnsSettlement() async throws {
        // Given
        let mockRepository = MockSettlementRepository()
        let expectedSettlement = TravelSettlement(
            balances: [
                MemberBalance(id: "1", memberId: "m1", name: "홍길동", balance: 50000)
            ],
            savedSettlements: [],
            recommendedSettlements: [
                Settlement(
                    id: "1",
                    fromMemberName: "김철수",
                    toMemberName: "홍길동",
                    amount: 30000,
                    status: .pending
                )
            ]
        )
        await mockRepository.setMockSettlement(expectedSettlement)

        // When
        let result = try await withDependencies {
            $0.settlementRepository = mockRepository
        } operation: {
            let sut = FetchSettlementUseCase()
            return try await sut.execute(travelId: "travel-123")
        }

        // Then
        #expect(result == expectedSettlement)
    }

    /// TC-FETCH-002: 정산 데이터에 모든 필수 필드 포함 확인
    @Test("정산 데이터에 모든 필수 필드 포함 확인")
    func fetchSettlement_returnsAllRequiredFields() async throws {
        // Given
        let mockRepository = MockSettlementRepository()
        let expectedSettlement = TravelSettlement(
            balances: [
                MemberBalance(id: "1", memberId: "m1", name: "홍길동", balance: 50000),
                MemberBalance(id: "2", memberId: "m2", name: "김철수", balance: -30000),
                MemberBalance(id: "3", memberId: "m3", name: "이영희", balance: -20000)
            ],
            savedSettlements: [
                Settlement(
                    id: "saved-1",
                    fromMemberName: "김철수",
                    toMemberName: "홍길동",
                    amount: 30000,
                    status: .completed
                )
            ],
            recommendedSettlements: [
                Settlement(
                    id: "rec-1",
                    fromMemberName: "김철수",
                    toMemberName: "홍길동",
                    amount: 30000,
                    status: .pending
                ),
                Settlement(
                    id: "rec-2",
                    fromMemberName: "이영희",
                    toMemberName: "홍길동",
                    amount: 20000,
                    status: .pending
                )
            ]
        )
        await mockRepository.setMockSettlement(expectedSettlement)

        // When
        let result = try await withDependencies {
            $0.settlementRepository = mockRepository
        } operation: {
            let sut = FetchSettlementUseCase()
            return try await sut.execute(travelId: "travel-123")
        }

        // Then
        #expect(result.balances.count == 3)
        #expect(result.savedSettlements.count == 1)
        #expect(result.recommendedSettlements.count == 2)
    }

    // MARK: - Edge Cases

    /// TC-FETCH-003: 빈 balances 반환
    @Test("빈 balances 반환 시 정상 처리")
    func fetchSettlement_withEmptyBalances_succeeds() async throws {
        // Given
        let mockRepository = MockSettlementRepository()
        let expectedSettlement = TravelSettlement(
            balances: [],
            savedSettlements: [
                Settlement(
                    id: "saved-1",
                    fromMemberName: "김철수",
                    toMemberName: "홍길동",
                    amount: 30000,
                    status: .completed
                )
            ],
            recommendedSettlements: [
                Settlement(
                    id: "rec-1",
                    fromMemberName: "이영희",
                    toMemberName: "홍길동",
                    amount: 20000,
                    status: .pending
                )
            ]
        )
        await mockRepository.setMockSettlement(expectedSettlement)

        // When
        let result = try await withDependencies {
            $0.settlementRepository = mockRepository
        } operation: {
            let sut = FetchSettlementUseCase()
            return try await sut.execute(travelId: "travel-123")
        }

        // Then
        #expect(result.balances.isEmpty == true)
        #expect(result.savedSettlements.isEmpty == false)
        #expect(result.recommendedSettlements.isEmpty == false)
    }

    /// TC-FETCH-004: 빈 recommendedSettlements 반환
    @Test("빈 recommendedSettlements 반환 시 정상 처리")
    func fetchSettlement_withEmptyRecommendedSettlements_succeeds() async throws {
        // Given
        let mockRepository = MockSettlementRepository()
        let expectedSettlement = TravelSettlement(
            balances: [
                MemberBalance(id: "1", memberId: "m1", name: "홍길동", balance: 0)
            ],
            savedSettlements: [],
            recommendedSettlements: []
        )
        await mockRepository.setMockSettlement(expectedSettlement)

        // When
        let result = try await withDependencies {
            $0.settlementRepository = mockRepository
        } operation: {
            let sut = FetchSettlementUseCase()
            return try await sut.execute(travelId: "travel-123")
        }

        // Then
        #expect(result.recommendedSettlements.isEmpty == true)
    }

    /// TC-FETCH-005: 빈 savedSettlements 반환
    @Test("빈 savedSettlements 반환 시 정상 처리")
    func fetchSettlement_withEmptySavedSettlements_succeeds() async throws {
        // Given
        let mockRepository = MockSettlementRepository()
        let expectedSettlement = TravelSettlement(
            balances: [
                MemberBalance(id: "1", memberId: "m1", name: "홍길동", balance: 50000)
            ],
            savedSettlements: [],
            recommendedSettlements: [
                Settlement(
                    id: "rec-1",
                    fromMemberName: "김철수",
                    toMemberName: "홍길동",
                    amount: 30000,
                    status: .pending
                )
            ]
        )
        await mockRepository.setMockSettlement(expectedSettlement)

        // When
        let result = try await withDependencies {
            $0.settlementRepository = mockRepository
        } operation: {
            let sut = FetchSettlementUseCase()
            return try await sut.execute(travelId: "travel-123")
        }

        // Then
        #expect(result.savedSettlements.isEmpty == true)
    }

    /// TC-FETCH-006: 모든 배열이 빈 TravelSettlement 반환
    @Test("모든 배열이 빈 TravelSettlement 반환 시 정상 처리")
    func fetchSettlement_withAllEmptyArrays_succeeds() async throws {
        // Given
        let mockRepository = MockSettlementRepository()
        let expectedSettlement = TravelSettlement(
            balances: [],
            savedSettlements: [],
            recommendedSettlements: []
        )
        await mockRepository.setMockSettlement(expectedSettlement)

        // When
        let result = try await withDependencies {
            $0.settlementRepository = mockRepository
        } operation: {
            let sut = FetchSettlementUseCase()
            return try await sut.execute(travelId: "travel-123")
        }

        // Then
        #expect(result.balances.isEmpty == true)
        #expect(result.savedSettlements.isEmpty == true)
        #expect(result.recommendedSettlements.isEmpty == true)
    }

    // MARK: - Error Cases

    /// TC-FETCH-007: Repository 조회 실패 시 에러 전파
    @Test("Repository 조회 실패 시 에러 전파")
    func fetchSettlement_whenRepositoryFails_throwsError() async throws {
        // Given
        let mockRepository = MockSettlementRepository()
        await mockRepository.setShouldFail(true)

        // When/Then
        await withDependencies {
            $0.settlementRepository = mockRepository
        } operation: {
            let sut = FetchSettlementUseCase()

            await #expect(throws: SettlementRepositoryError.self) {
                try await sut.execute(travelId: "travel-123")
            }
        }
    }

    /// TC-FETCH-008: 빈 travelId로 조회 시도
    @Test("빈 travelId로 조회 시 Repository에 전달")
    func fetchSettlement_withEmptyTravelId_passesToRepository() async throws {
        // Given
        let mockRepository = MockSettlementRepository()
        let expectedSettlement = TravelSettlement.mock
        await mockRepository.setMockSettlement(expectedSettlement)

        // When - 현재 구현에서는 빈 travelId도 Repository에 그대로 전달됨
        let result = try await withDependencies {
            $0.settlementRepository = mockRepository
        } operation: {
            let sut = FetchSettlementUseCase()
            return try await sut.execute(travelId: "")
        }

        // Then - Mock이 설정되어 있으므로 정상 반환
        #expect(result == expectedSettlement)
    }

    /// TC-FETCH-009: 존재하지 않는 travelId로 조회 (Mock 기본 동작 확인)
    @Test("존재하지 않는 travelId로 조회 시 기본 mock 데이터 반환")
    func fetchSettlement_withNonExistentTravelId_returnsDefaultMock() async throws {
        // Given
        let mockRepository = MockSettlementRepository()
        // mockSettlement를 설정하지 않으면 기본 TravelSettlement.mock 반환

        // When
        let result = try await withDependencies {
            $0.settlementRepository = mockRepository
        } operation: {
            let sut = FetchSettlementUseCase()
            return try await sut.execute(travelId: "non-existent-id")
        }

        // Then - 기본 mock 데이터가 반환됨
        #expect(result == TravelSettlement.mock)
    }

    // MARK: - Data Integrity Tests

    /// TC-FETCH-010: Settlement 상태별 필터링 검증
    @Test("다양한 상태의 Settlement이 올바르게 반환됨")
    func fetchSettlement_withVariousStatuses_returnsAllStatuses() async throws {
        // Given
        let mockRepository = MockSettlementRepository()
        let expectedSettlement = TravelSettlement(
            balances: [
                MemberBalance(id: "1", memberId: "m1", name: "홍길동", balance: 50000)
            ],
            savedSettlements: [],
            recommendedSettlements: [
                Settlement(
                    id: "1",
                    fromMemberName: "김철수",
                    toMemberName: "홍길동",
                    amount: 30000,
                    status: .pending
                ),
                Settlement(
                    id: "2",
                    fromMemberName: "이영희",
                    toMemberName: "홍길동",
                    amount: 20000,
                    status: .completed
                ),
                Settlement(
                    id: "3",
                    fromMemberName: "박민수",
                    toMemberName: "홍길동",
                    amount: 10000,
                    status: .cancelled
                )
            ]
        )
        await mockRepository.setMockSettlement(expectedSettlement)

        // When
        let result = try await withDependencies {
            $0.settlementRepository = mockRepository
        } operation: {
            let sut = FetchSettlementUseCase()
            return try await sut.execute(travelId: "travel-123")
        }

        // Then
        #expect(result.recommendedSettlements.count == 3)

        let pendingSettlement = result.recommendedSettlements.first { $0.id == "1" }
        #expect(pendingSettlement?.status == .pending)

        let completedSettlement = result.recommendedSettlements.first { $0.id == "2" }
        #expect(completedSettlement?.status == .completed)

        let cancelledSettlement = result.recommendedSettlements.first { $0.id == "3" }
        #expect(cancelledSettlement?.status == .cancelled)
    }

    /// TC-FETCH-011: MemberBalance 양수/음수 잔액 검증
    @Test("양수, 음수, 0 잔액이 올바르게 반환됨")
    func fetchSettlement_withVariousBalances_returnsCorrectValues() async throws {
        // Given
        let mockRepository = MockSettlementRepository()
        let expectedSettlement = TravelSettlement(
            balances: [
                MemberBalance(id: "1", memberId: "m1", name: "홍길동", balance: 50000),   // 양수 (받을 돈)
                MemberBalance(id: "2", memberId: "m2", name: "김철수", balance: -30000),  // 음수 (줄 돈)
                MemberBalance(id: "3", memberId: "m3", name: "이영희", balance: 0)        // 0 (정산 완료)
            ],
            savedSettlements: [],
            recommendedSettlements: []
        )
        await mockRepository.setMockSettlement(expectedSettlement)

        // When
        let result = try await withDependencies {
            $0.settlementRepository = mockRepository
        } operation: {
            let sut = FetchSettlementUseCase()
            return try await sut.execute(travelId: "travel-123")
        }

        // Then
        #expect(result.balances.count == 3)

        let positiveBalance = result.balances.first { $0.memberId == "m1" }
        #expect(positiveBalance?.balance == 50000)
        #expect(positiveBalance!.balance > 0)

        let negativeBalance = result.balances.first { $0.memberId == "m2" }
        #expect(negativeBalance?.balance == -30000)
        #expect(negativeBalance!.balance < 0)

        let zeroBalance = result.balances.first { $0.memberId == "m3" }
        #expect(zeroBalance?.balance == 0)
    }
}
