# Settlement Domain Test Plan

## Overview

Settlement 도메인의 UseCase 테스트 계획서입니다.

### UseCase 목록
| UseCase | 설명 | 기존 테스트 현황 |
|---------|------|-----------------|
| FetchSettlementUseCase | 정산 조회 | 없음 (신규 작성 필요) |
| CalculateSettlementUseCase | 정산 계산 | 13개 TC 존재 |

### Entity 구조
- **TravelSettlement**: balances, savedSettlements, recommendedSettlements
- **Settlement**: id, fromMemberName, toMemberName, amount, status, updatedAt
- **SettlementCalculation**: totalExpenseAmount, myShareAmount, totalPersonCount, averagePerPerson, myNetBalance, paymentsToMake, paymentsToReceive, memberDetails
- **MemberBalance**: id, memberId, name, balance
- **MemberSettlementDetail**: id, memberId, memberName, netBalance, totalPaid, totalOwe, paidExpenses, sharedExpenses

### Mock 현황
- **MockSettlementRepository**: actor 기반, setShouldFail(), setMockSettlement(), reset() 지원
- **MockFetchSettlementUseCase**: 단순 mock 반환 (TravelSettlement.mock)

---

## 1. FetchSettlementUseCase Tests (신규 작성 필요)

### 1.1 Happy Path

#### TC-FETCH-001: 유효한 travelId로 정산 조회 성공
- **우선순위**: P0
- **테스트 목적**: 유효한 travelId로 정산 데이터를 성공적으로 조회할 수 있는지 검증
- **Given**:
  - MockSettlementRepository에 mock 정산 데이터가 설정됨
  - 유효한 travelId = "travel-123"
- **When**:
  - FetchSettlementUseCase.execute(travelId: "travel-123") 호출
- **Then**:
  - TravelSettlement 객체가 반환됨
  - balances, savedSettlements, recommendedSettlements가 포함됨

#### TC-FETCH-002: 정산 데이터에 모든 필수 필드 포함 확인
- **우선순위**: P0
- **테스트 목적**: 반환된 TravelSettlement에 balances, savedSettlements, recommendedSettlements가 모두 포함되는지 검증
- **Given**:
  - MockSettlementRepository에 balances 3개, savedSettlements 1개, recommendedSettlements 2개가 포함된 mock 데이터 설정
- **When**:
  - FetchSettlementUseCase.execute(travelId:) 호출
- **Then**:
  - result.balances.count == 3
  - result.savedSettlements.count == 1
  - result.recommendedSettlements.count == 2

---

### 1.2 Edge Cases

#### TC-FETCH-003: 빈 balances 반환
- **우선순위**: P1
- **테스트 목적**: balances가 빈 배열인 경우에도 정상적으로 처리되는지 검증
- **Given**:
  - MockSettlementRepository에 빈 balances를 가진 TravelSettlement 설정
  ```swift
  TravelSettlement(
      balances: [],
      savedSettlements: [Settlement(...)],
      recommendedSettlements: [Settlement(...)]
  )
  ```
- **When**:
  - FetchSettlementUseCase.execute(travelId:) 호출
- **Then**:
  - result.balances.isEmpty == true
  - 에러가 발생하지 않음

#### TC-FETCH-004: 빈 recommendedSettlements 반환
- **우선순위**: P1
- **테스트 목적**: 추천 정산 내역이 없는 경우에도 정상적으로 처리되는지 검증
- **Given**:
  - MockSettlementRepository에 빈 recommendedSettlements를 가진 TravelSettlement 설정
  ```swift
  TravelSettlement(
      balances: [MemberBalance(...)],
      savedSettlements: [],
      recommendedSettlements: []
  )
  ```
- **When**:
  - FetchSettlementUseCase.execute(travelId:) 호출
- **Then**:
  - result.recommendedSettlements.isEmpty == true
  - 에러가 발생하지 않음

#### TC-FETCH-005: 빈 savedSettlements 반환
- **우선순위**: P1
- **테스트 목적**: 저장된 정산 내역이 없는 경우에도 정상적으로 처리되는지 검증
- **Given**:
  - MockSettlementRepository에 빈 savedSettlements를 가진 TravelSettlement 설정
- **When**:
  - FetchSettlementUseCase.execute(travelId:) 호출
- **Then**:
  - result.savedSettlements.isEmpty == true
  - 에러가 발생하지 않음

#### TC-FETCH-006: 모든 배열이 빈 TravelSettlement 반환
- **우선순위**: P2
- **테스트 목적**: 모든 필드가 빈 배열인 경우에도 정상적으로 처리되는지 검증
- **Given**:
  - MockSettlementRepository에 모든 배열이 빈 TravelSettlement 설정
  ```swift
  TravelSettlement(balances: [], savedSettlements: [], recommendedSettlements: [])
  ```
- **When**:
  - FetchSettlementUseCase.execute(travelId:) 호출
- **Then**:
  - 정상적으로 빈 TravelSettlement 반환
  - 에러가 발생하지 않음

---

### 1.3 Error Cases

#### TC-FETCH-007: Repository 조회 실패 시 에러 전파
- **우선순위**: P0
- **테스트 목적**: Repository에서 에러가 발생했을 때 UseCase가 에러를 올바르게 전파하는지 검증
- **Given**:
  - MockSettlementRepository.setShouldFail(true) 설정
- **When**:
  - FetchSettlementUseCase.execute(travelId:) 호출
- **Then**:
  - SettlementRepositoryError.fetchFailed가 throw됨
  - 에러 메시지에 "Mock fetch failed" 포함

#### TC-FETCH-008: 빈 travelId로 조회 시도
- **우선순위**: P1
- **테스트 목적**: 빈 문자열 travelId로 조회 시 동작 검증
- **Given**:
  - travelId = ""
- **When**:
  - FetchSettlementUseCase.execute(travelId: "") 호출
- **Then**:
  - 현재 구현: Repository에 그대로 전달됨 (별도 validation 없음)
  - 권장: InvalidInput 에러 throw 또는 Repository에서 처리

#### TC-FETCH-009: 존재하지 않는 travelId로 조회
- **우선순위**: P1
- **테스트 목적**: 존재하지 않는 여행 ID로 조회 시 적절한 에러 처리 검증
- **Given**:
  - MockSettlementRepository에서 해당 travelId에 대한 데이터가 없도록 설정
  - (현재 Mock은 항상 기본값 반환하므로 실제 Repository 테스트에서 검증 필요)
- **When**:
  - FetchSettlementUseCase.execute(travelId: "non-existent-id") 호출
- **Then**:
  - NotFound 에러 또는 빈 결과 반환

---

### 1.4 Data Integrity Tests

#### TC-FETCH-010: Settlement 상태별 필터링 검증
- **우선순위**: P2
- **테스트 목적**: 다양한 상태(pending, completed, cancelled)의 Settlement이 올바르게 반환되는지 검증
- **Given**:
  - MockSettlementRepository에 다양한 상태의 Settlement 포함된 데이터 설정
  ```swift
  recommendedSettlements: [
      Settlement(id: "1", ..., status: .pending),
      Settlement(id: "2", ..., status: .completed),
      Settlement(id: "3", ..., status: .cancelled)
  ]
  ```
- **When**:
  - FetchSettlementUseCase.execute(travelId:) 호출
- **Then**:
  - 모든 상태의 Settlement이 포함되어 반환됨
  - 각 Settlement의 status가 올바르게 매핑됨

#### TC-FETCH-011: MemberBalance 양수/음수 잔액 검증
- **우선순위**: P2
- **테스트 목적**: 양수(받을 돈)와 음수(줄 돈) 잔액이 올바르게 반환되는지 검증
- **Given**:
  - balances에 양수, 음수, 0 잔액을 가진 멤버 포함
  ```swift
  balances: [
      MemberBalance(id: "1", memberId: "m1", name: "A", balance: 50000),
      MemberBalance(id: "2", memberId: "m2", name: "B", balance: -30000),
      MemberBalance(id: "3", memberId: "m3", name: "C", balance: 0)
  ]
  ```
- **When**:
  - FetchSettlementUseCase.execute(travelId:) 호출
- **Then**:
  - 각 MemberBalance의 balance 값이 정확히 유지됨

---

## 2. CalculateSettlementUseCase Tests (기존 테스트 분석)

### 기존 테스트 케이스 (13개)

| TC ID | 테스트명 | 카테고리 | 설명 |
|-------|----------|----------|------|
| 1 | noExpenses | Edge Case | 지출이 없을 때 모든 값이 0 |
| 2 | totalExpenseAmount_singleExpense | Happy Path | 총 지출 금액 계산 - 단일 지출 |
| 3 | totalExpenseAmount_multipleExpenses | Happy Path | 총 지출 금액 계산 - 여러 지출 |
| 4 | myShareAmount_allExpenses | Happy Path | 내 부담 금액 계산 - 모든 지출에 참여 |
| 5 | myShareAmount_partialExpenses | Edge Case | 내 부담 금액 계산 - 일부 지출만 참여 |
| 6 | averagePerPerson | Happy Path | 1인 평균 지출 계산 |
| 7 | allMembersPayEqually | Edge Case | 모든 멤버가 균등하게 결제한 경우 - 정산 없음 |
| 8 | iDidNotPayAnything | Edge Case | 내가 아무것도 결제하지 않은 경우 - 빚만 있음 |
| 9 | iPaidEverything | Edge Case | 내가 모든 것을 결제한 경우 - 받을 돈만 있음 |
| 10 | partialParticipation | Complex | 일부 지출에만 참여 - 참여하지 않은 지출은 제외 |
| 11 | complexPayerChanges | Complex | 결제자가 여러 번 바뀌는 복잡한 시나리오 |
| 12 | mixedParticipantCounts | Complex | 2명만 참여하는 지출이 섞인 경우 |
| 13 | iPaidLessThanOthers | Edge Case | 내가 다른 사람들보다 적게 낸 경우 |

### 커버리지 분석

#### 잘 커버된 영역
- 기본 정산 계산 로직
- 다양한 참여자 조합
- myNetBalance 계산
- paymentsToMake / paymentsToReceive 계산
- memberDetails 검증

#### 추가 테스트 권장 (선택적)

#### TC-CALC-014: currentUserId가 nil인 경우
- **우선순위**: P2
- **테스트 목적**: currentUserId가 nil일 때의 동작 검증
- **Given**:
  - expenses 배열에 지출 데이터 존재
  - currentUserId = nil
- **When**:
  - CalculateSettlementUseCase.execute(expenses:, currentUserId: nil) 호출
- **Then**:
  - myShareAmount, myNetBalance 등 "my" 관련 값이 0 또는 적절한 기본값

#### TC-CALC-015: 단일 멤버만 있는 경우
- **우선순위**: P2
- **테스트 목적**: 혼자 여행한 경우의 정산 계산
- **Given**:
  - 1명의 멤버만 참여하는 지출
- **When**:
  - CalculateSettlementUseCase.execute(...) 호출
- **Then**:
  - totalPersonCount == 1
  - paymentsToMake, paymentsToReceive 모두 빈 배열

#### TC-CALC-016: 대용량 지출 데이터 처리
- **우선순위**: P2
- **테스트 목적**: 많은 지출 데이터 처리 시 성능 및 정확성 검증
- **Given**:
  - 100개 이상의 지출 데이터
- **When**:
  - CalculateSettlementUseCase.execute(...) 호출
- **Then**:
  - 정확한 계산 결과 반환
  - 합리적인 시간 내 완료

#### TC-CALC-017: 소수점 금액 처리
- **우선순위**: P1
- **테스트 목적**: 나누어 떨어지지 않는 금액의 처리 검증
- **Given**:
  - amount = 100 (3명이 나누면 33.33...)
- **When**:
  - CalculateSettlementUseCase.execute(...) 호출
- **Then**:
  - 반올림/버림 처리가 일관되게 적용됨

---

## 3. 테스트 우선순위 요약

### P0 (필수 - 즉시 구현)
- [ ] TC-FETCH-001: 유효한 travelId로 정산 조회 성공
- [ ] TC-FETCH-002: 정산 데이터에 모든 필수 필드 포함 확인
- [ ] TC-FETCH-007: Repository 조회 실패 시 에러 전파

### P1 (중요 - 1차 마일스톤)
- [ ] TC-FETCH-003: 빈 balances 반환
- [ ] TC-FETCH-004: 빈 recommendedSettlements 반환
- [ ] TC-FETCH-005: 빈 savedSettlements 반환
- [ ] TC-FETCH-008: 빈 travelId로 조회 시도
- [ ] TC-FETCH-009: 존재하지 않는 travelId로 조회
- [ ] TC-CALC-017: 소수점 금액 처리

### P2 (권장 - 2차 마일스톤)
- [ ] TC-FETCH-006: 모든 배열이 빈 TravelSettlement 반환
- [ ] TC-FETCH-010: Settlement 상태별 필터링 검증
- [ ] TC-FETCH-011: MemberBalance 양수/음수 잔액 검증
- [ ] TC-CALC-014: currentUserId가 nil인 경우
- [ ] TC-CALC-015: 단일 멤버만 있는 경우
- [ ] TC-CALC-016: 대용량 지출 데이터 처리

---

## 4. 테스트 파일 구조

```
Domain/Tests/
├── UseCase/
│   └── Settlement/
│       ├── CalculateSettlementUseCaseTests.swift  (기존 - 13개 TC)
│       └── FetchSettlementUseCaseTests.swift      (신규 작성 필요)
└── Reports/
    └── SettlementTestPlan.md                      (현재 문서)
```

---

## 5. 구현 가이드

### FetchSettlementUseCaseTests.swift 템플릿

```swift
import Testing
@testable import Domain
import Dependencies

@Suite("정산 조회 UseCase 테스트", .tags(.useCase, .settlement))
struct FetchSettlementUseCaseTests {

    // MARK: - Happy Path

    @Test("유효한 travelId로 정산 조회 성공")
    func fetchSettlement_withValidTravelId_returnsSettlement() async throws {
        // given
        let mockRepository = MockSettlementRepository()
        let expectedSettlement = TravelSettlement.mock
        await mockRepository.setMockSettlement(expectedSettlement)

        let useCase = withDependencies {
            $0.settlementRepository = mockRepository
        } operation: {
            FetchSettlementUseCase()
        }

        // when
        let result = try await useCase.execute(travelId: "travel-123")

        // then
        #expect(result == expectedSettlement)
    }

    // MARK: - Error Cases

    @Test("Repository 조회 실패 시 에러 전파")
    func fetchSettlement_whenRepositoryFails_throwsError() async throws {
        // given
        let mockRepository = MockSettlementRepository()
        await mockRepository.setShouldFail(true)

        let useCase = withDependencies {
            $0.settlementRepository = mockRepository
        } operation: {
            FetchSettlementUseCase()
        }

        // when/then
        await #expect(throws: SettlementRepositoryError.self) {
            try await useCase.execute(travelId: "travel-123")
        }
    }

    // ... 추가 테스트
}
```

---

## 6. 변경 이력

| 날짜 | 버전 | 변경 내용 | 작성자 |
|------|------|----------|--------|
| 2026-01-29 | 1.0 | 최초 작성 | Claude |
