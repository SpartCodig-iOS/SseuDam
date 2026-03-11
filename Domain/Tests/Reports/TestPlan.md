# Expense Domain Test Plan

## Overview

이 문서는 Expense 도메인의 UseCase 테스트 계획을 정의합니다.

### UseCase 목록
| UseCase | 설명 | 프로토콜 시그니처 |
|---------|------|------------------|
| CreateExpenseUseCase | 지출 생성 | `execute(travelId: String, input: ExpenseInput) async throws` |
| DeleteExpenseUseCase | 지출 삭제 | `execute(travelId: String, expenseId: String) async throws` |
| FetchTravelExpenseUseCase | 여행별 지출 조회 | `execute(travelId: String, date: Date?) -> AsyncStream<Result<[Expense], Error>>` |
| UpdateExpenseUseCase | 지출 수정 | `execute(travelId: String, expenseId: String, input: ExpenseInput) async throws` |

### Entity 구조
```swift
struct ExpenseInput {
    let title: String
    let amount: Double
    let currency: String
    let expenseDate: Date
    let category: ExpenseCategory
    let payerId: String
    let participantIds: [String]
}

struct Expense: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let amount: Double
    let currency: String
    let convertedAmount: Double
    let expenseDate: Date
    let category: ExpenseCategory
    let payer: TravelMember
    let participants: [TravelMember]
}

enum ExpenseError: Error, Equatable {
    case invalidAmount(Double)
    case invalidCurrency(String)
    case invalidDate
    case emptyTitle
    case invalidParticipants
    case payerNotInParticipants
}
```

### Mock 현황
- `MockExpenseRepository` - actor 기반, 저장/수정 실패 시뮬레이션 지원
- `MockDeleteExpenseUseCase`, `MockFetchTravelExpenseUseCase`, `MockUpdateExpenseUseCase` 존재

### 기존 테스트 현황
- `ExpenseValidationTests.swift` - 구조 업데이트 필요 (old: payerId/payerName -> new: payer: TravelMember)

---

## 1. CreateExpenseUseCase Tests

### Happy Path

#### TC-001: 유효한 입력으로 지출 생성 성공
- **테스트 목적**: 모든 필수 필드가 유효할 때 지출이 정상적으로 생성되는지 확인
- **우선순위**: P0
- **Given**:
  - travelId: "travel-123"
  - title: "점심 식사"
  - amount: 50000.0
  - currency: "KRW"
  - expenseDate: Date() (현재 날짜)
  - category: .foodAndDrink
  - payerId: "user1"
  - participantIds: ["user1", "user2", "user3"]
- **When**: `execute(travelId:input:)` 호출
- **Then**: 에러 없이 완료, Repository의 `save` 메서드가 호출됨
- **예상 결과**: 성공 (throws 없음)

#### TC-002: 다양한 카테고리로 지출 생성 성공
- **테스트 목적**: 모든 ExpenseCategory 타입에서 지출 생성이 가능한지 확인
- **우선순위**: P1
- **Given**: 각 카테고리별 유효한 ExpenseInput
- **When**: 각 카테고리로 `execute` 호출
- **Then**: 모든 카테고리에서 에러 없이 완료
- **예상 결과**: 6개 카테고리 모두 성공 (accommodation, foodAndDrink, transportation, activity, shopping, other)

### Edge Cases

#### TC-003: 금액이 0.01인 경우 (최소 양수)
- **테스트 목적**: 최소 유효 금액에서 지출 생성이 가능한지 확인
- **우선순위**: P2
- **Given**: amount: 0.01, 나머지 필드 유효
- **When**: `execute(travelId:input:)` 호출
- **Then**: 에러 없이 완료
- **예상 결과**: 성공

#### TC-004: 참가자가 1명인 경우 (지불자 = 단일 참가자)
- **테스트 목적**: 지불자와 참가자가 동일한 1명일 때 정상 동작 확인
- **우선순위**: P1
- **Given**:
  - payerId: "user1"
  - participantIds: ["user1"]
- **When**: `execute(travelId:input:)` 호출
- **Then**: 에러 없이 완료
- **예상 결과**: 성공

#### TC-005: 금액이 매우 큰 경우
- **테스트 목적**: 대용량 금액 처리 가능 여부 확인
- **우선순위**: P2
- **Given**: amount: 999_999_999.99
- **When**: `execute(travelId:input:)` 호출
- **Then**: 에러 없이 완료
- **예상 결과**: 성공

#### TC-006: 제목에 특수문자 포함
- **테스트 목적**: 특수문자가 포함된 제목 처리 가능 여부 확인
- **우선순위**: P2
- **Given**: title: "점심 (맛집!) - 강남역 #맛집 @친구들"
- **When**: `execute(travelId:input:)` 호출
- **Then**: 에러 없이 완료
- **예상 결과**: 성공

#### TC-007: 참가자가 다수인 경우 (10명 이상)
- **테스트 목적**: 다수의 참가자가 있을 때 정상 동작 확인
- **우선순위**: P2
- **Given**: participantIds: ["user1", ..., "user15"] (15명)
- **When**: `execute(travelId:input:)` 호출
- **Then**: 에러 없이 완료
- **예상 결과**: 성공

### Error Cases - Validation

#### TC-008: 금액이 음수인 경우
- **테스트 목적**: 음수 금액 입력 시 적절한 에러 발생 확인
- **우선순위**: P0
- **Given**: amount: -1000.0
- **When**: `execute(travelId:input:)` 호출
- **Then**: `ExpenseError.invalidAmount(-1000.0)` throw
- **예상 결과**: 에러 발생

#### TC-009: 금액이 0인 경우
- **테스트 목적**: 0원 입력 시 적절한 에러 발생 확인
- **우선순위**: P0
- **Given**: amount: 0.0
- **When**: `execute(travelId:input:)` 호출
- **Then**: `ExpenseError.invalidAmount(0.0)` throw
- **예상 결과**: 에러 발생

#### TC-010: 제목이 빈 문자열인 경우
- **테스트 목적**: 빈 제목 입력 시 적절한 에러 발생 확인
- **우선순위**: P0
- **Given**: title: ""
- **When**: `execute(travelId:input:)` 호출
- **Then**: `ExpenseError.emptyTitle` throw
- **예상 결과**: 에러 발생

#### TC-011: 제목이 공백만 있는 경우
- **테스트 목적**: 공백만 있는 제목 입력 시 적절한 에러 발생 확인
- **우선순위**: P0
- **Given**: title: "   " (공백 3개)
- **When**: `execute(travelId:input:)` 호출
- **Then**: `ExpenseError.emptyTitle` throw
- **예상 결과**: 에러 발생

#### TC-012: 참가자가 없는 경우 (빈 배열)
- **테스트 목적**: 참가자 없이 지출 생성 시 적절한 에러 발생 확인
- **우선순위**: P0
- **Given**: participantIds: []
- **When**: `execute(travelId:input:)` 호출
- **Then**: `ExpenseError.invalidParticipants` throw
- **예상 결과**: 에러 발생

#### TC-013: 지불자가 참가자 목록에 없는 경우
- **테스트 목적**: 지불자가 참가자에 포함되지 않을 때 적절한 에러 발생 확인
- **우선순위**: P0
- **Given**:
  - payerId: "user1"
  - participantIds: ["user2", "user3"]
- **When**: `execute(travelId:input:)` 호출
- **Then**: `ExpenseError.payerNotInParticipants` throw
- **예상 결과**: 에러 발생

### Error Cases - Repository

#### TC-014: Repository 저장 실패 시
- **테스트 목적**: Repository에서 저장 실패 시 에러가 올바르게 전파되는지 확인
- **우선순위**: P1
- **Given**:
  - MockExpenseRepository.setShouldFailSave(true, reason: "Network error")
  - 유효한 ExpenseInput
- **When**: `execute(travelId:input:)` 호출
- **Then**: `ExpenseRepositoryError.saveFailed(reason: "Network error")` throw
- **예상 결과**: 에러 발생

---

## 2. DeleteExpenseUseCase Tests

### Happy Path

#### TC-015: 존재하는 지출 삭제 성공
- **테스트 목적**: 유효한 expenseId로 지출 삭제가 정상 동작하는지 확인
- **우선순위**: P0
- **Given**:
  - travelId: "travel-123"
  - expenseId: "expense-456"
- **When**: `execute(travelId:expenseId:)` 호출
- **Then**: 에러 없이 완료, Repository의 `delete` 메서드가 호출됨
- **예상 결과**: 성공 (throws 없음)

### Edge Cases

#### TC-016: 빈 expenseId로 삭제 시도
- **테스트 목적**: 빈 문자열 expenseId 처리 확인 (Repository 레벨에서 처리)
- **우선순위**: P2
- **Given**: expenseId: ""
- **When**: `execute(travelId:expenseId:)` 호출
- **Then**: Repository 동작에 따라 결정 (현재 구현상 성공 가능)
- **예상 결과**: 구현 확인 필요

#### TC-017: 존재하지 않는 expenseId로 삭제 시도
- **테스트 목적**: 존재하지 않는 지출 삭제 시 동작 확인
- **우선순위**: P1
- **Given**: expenseId: "non-existent-id"
- **When**: `execute(travelId:expenseId:)` 호출
- **Then**: 구현에 따라 성공 또는 에러 (idempotent 설계 권장)
- **예상 결과**: 구현 확인 필요

### Error Cases

#### TC-018: Repository 삭제 실패 시
- **테스트 목적**: Repository에서 삭제 실패 시 에러가 올바르게 전파되는지 확인
- **우선순위**: P1
- **Given**: Repository가 삭제 시 에러를 throw하도록 설정
- **When**: `execute(travelId:expenseId:)` 호출
- **Then**: 에러가 UseCase에서 그대로 전파됨
- **예상 결과**: 에러 발생

---

## 3. FetchTravelExpenseUseCase Tests

### Happy Path

#### TC-019: 지출 목록 조회 성공 (날짜 필터 없음)
- **테스트 목적**: travelId로 지출 목록을 성공적으로 조회하는지 확인
- **우선순위**: P0
- **Given**:
  - travelId: "travel-123"
  - date: nil
- **When**: `execute(travelId:date:)` 호출하고 AsyncStream 소비
- **Then**: Result.success([Expense]) 수신
- **예상 결과**: mockList 반환

#### TC-020: 특정 날짜의 지출만 조회 (날짜 필터 적용)
- **테스트 목적**: 날짜 필터가 올바르게 적용되는지 확인
- **우선순위**: P0
- **Given**:
  - travelId: "travel-123"
  - date: 특정 Date 객체
- **When**: `execute(travelId:date:)` 호출하고 AsyncStream 소비
- **Then**: 해당 날짜의 지출만 포함된 배열 반환
- **예상 결과**: 필터링된 결과

#### TC-021: 빈 지출 목록 조회
- **테스트 목적**: 지출이 없는 여행의 조회 결과 확인
- **우선순위**: P1
- **Given**:
  - MockExpenseRepository가 빈 배열 반환하도록 설정
  - travelId: "empty-travel"
- **When**: `execute(travelId:date:)` 호출
- **Then**: Result.success([]) 수신
- **예상 결과**: 빈 배열

### Edge Cases

#### TC-022: 해당 날짜에 지출이 없는 경우
- **테스트 목적**: 필터 날짜에 지출이 없을 때 빈 배열 반환 확인
- **우선순위**: P1
- **Given**:
  - date: 지출이 없는 날짜 (예: 1년 전)
- **When**: `execute(travelId:date:)` 호출
- **Then**: Result.success([]) 수신
- **예상 결과**: 빈 배열

#### TC-023: AsyncStream이 여러 번 yield하는 경우
- **테스트 목적**: 실시간 업데이트 시 여러 결과를 올바르게 처리하는지 확인
- **우선순위**: P1
- **Given**: Repository가 여러 번 데이터를 yield하도록 설정
- **When**: `execute(travelId:date:)` 호출하고 모든 결과 수집
- **Then**: 모든 yield된 결과를 순서대로 수신
- **예상 결과**: 여러 Result 수신

#### TC-024: 날짜 경계값 테스트 (자정 기준)
- **테스트 목적**: 날짜 필터링이 Calendar.isDate(_:inSameDayAs:) 기준으로 동작하는지 확인
- **우선순위**: P2
- **Given**:
  - 자정 직전 (23:59:59) 지출
  - 자정 직후 (00:00:01) 지출
- **When**: 특정 날짜로 필터링
- **Then**: 같은 날의 지출만 반환
- **예상 결과**: Calendar 기준 동일 날짜만 포함

### Error Cases

#### TC-025: Repository 조회 실패 시
- **테스트 목적**: Repository에서 에러 발생 시 Result.failure 반환 확인
- **우선순위**: P1
- **Given**: Repository가 Result.failure를 yield하도록 설정
- **When**: `execute(travelId:date:)` 호출
- **Then**: Result.failure(Error) 수신
- **예상 결과**: 에러 포함된 Result

---

## 4. UpdateExpenseUseCase Tests

### Happy Path

#### TC-026: 지출 정보 수정 성공
- **테스트 목적**: 유효한 입력으로 지출 수정이 정상 동작하는지 확인
- **우선순위**: P0
- **Given**:
  - travelId: "travel-123"
  - expenseId: "expense-456"
  - 유효한 ExpenseInput (수정된 값)
- **When**: `execute(travelId:expenseId:input:)` 호출
- **Then**: 에러 없이 완료, Repository의 `update` 메서드가 호출됨
- **예상 결과**: 성공 (throws 없음)

#### TC-027: 제목만 수정
- **테스트 목적**: 부분 수정 시 정상 동작 확인
- **우선순위**: P1
- **Given**: 기존 지출의 title만 변경한 ExpenseInput
- **When**: `execute(travelId:expenseId:input:)` 호출
- **Then**: 에러 없이 완료
- **예상 결과**: 성공

#### TC-028: 금액만 수정
- **테스트 목적**: 금액 변경 시 정상 동작 확인
- **우선순위**: P1
- **Given**: 기존 지출의 amount만 변경한 ExpenseInput
- **When**: `execute(travelId:expenseId:input:)` 호출
- **Then**: 에러 없이 완료
- **예상 결과**: 성공

#### TC-029: 참가자 변경
- **테스트 목적**: 참가자 목록 변경 시 정상 동작 확인
- **우선순위**: P1
- **Given**: 기존 지출의 participantIds 변경한 ExpenseInput (payerId 포함 유지)
- **When**: `execute(travelId:expenseId:input:)` 호출
- **Then**: 에러 없이 완료
- **예상 결과**: 성공

#### TC-030: 지불자 변경 (새 지불자가 참가자에 포함)
- **테스트 목적**: 지불자 변경 시 정상 동작 확인
- **우선순위**: P1
- **Given**:
  - 새로운 payerId
  - participantIds에 새 payerId 포함
- **When**: `execute(travelId:expenseId:input:)` 호출
- **Then**: 에러 없이 완료
- **예상 결과**: 성공

### Edge Cases

#### TC-031: 동일한 값으로 수정 (변경 없음)
- **테스트 목적**: 값 변경 없이 수정 요청 시 정상 동작 확인
- **우선순위**: P2
- **Given**: 기존 값과 동일한 ExpenseInput
- **When**: `execute(travelId:expenseId:input:)` 호출
- **Then**: 에러 없이 완료
- **예상 결과**: 성공 (idempotent)

### Error Cases - Validation

#### TC-032: 수정 시 금액을 음수로 변경
- **테스트 목적**: 수정 시에도 validation이 적용되는지 확인
- **우선순위**: P0
- **Given**: amount: -5000.0
- **When**: `execute(travelId:expenseId:input:)` 호출
- **Then**: `ExpenseError.invalidAmount(-5000.0)` throw
- **예상 결과**: 에러 발생

#### TC-033: 수정 시 제목을 빈 문자열로 변경
- **테스트 목적**: 수정 시에도 validation이 적용되는지 확인
- **우선순위**: P0
- **Given**: title: ""
- **When**: `execute(travelId:expenseId:input:)` 호출
- **Then**: `ExpenseError.emptyTitle` throw
- **예상 결과**: 에러 발생

#### TC-034: 수정 시 참가자를 빈 배열로 변경
- **테스트 목적**: 수정 시에도 validation이 적용되는지 확인
- **우선순위**: P0
- **Given**: participantIds: []
- **When**: `execute(travelId:expenseId:input:)` 호출
- **Then**: `ExpenseError.invalidParticipants` throw
- **예상 결과**: 에러 발생

#### TC-035: 수정 시 지불자를 참가자에서 제외
- **테스트 목적**: 수정 시에도 validation이 적용되는지 확인
- **우선순위**: P0
- **Given**:
  - payerId: "user1"
  - participantIds: ["user2", "user3"] (user1 제외)
- **When**: `execute(travelId:expenseId:input:)` 호출
- **Then**: `ExpenseError.payerNotInParticipants` throw
- **예상 결과**: 에러 발생

### Error Cases - Repository

#### TC-036: Repository 수정 실패 시
- **테스트 목적**: Repository에서 수정 실패 시 에러가 올바르게 전파되는지 확인
- **우선순위**: P1
- **Given**:
  - MockExpenseRepository.setShouldFailUpdate(true)
  - 유효한 ExpenseInput
- **When**: `execute(travelId:expenseId:input:)` 호출
- **Then**: `ExpenseRepositoryError.updateFailed(reason:)` throw
- **예상 결과**: 에러 발생

---

## 5. ExpenseInput Validation Tests (Entity Level)

> Note: UseCase에서 `input.validate()`를 호출하므로, ExpenseInput의 validation 로직도 테스트 필요

#### TC-037: ExpenseInput - 모든 필드 유효
- **테스트 목적**: ExpenseInput.validate() 성공 케이스 확인
- **우선순위**: P0
- **Given**: 모든 필드가 유효한 ExpenseInput
- **When**: `validate()` 호출
- **Then**: 에러 없이 완료
- **예상 결과**: 성공

#### TC-038: ExpenseInput - 금액 검증 우선순위 확인
- **테스트 목적**: 여러 validation 실패 시 어떤 에러가 먼저 발생하는지 확인
- **우선순위**: P2
- **Given**: amount: -1000, title: "", participantIds: []
- **When**: `validate()` 호출
- **Then**: `ExpenseError.invalidAmount` throw (첫 번째 검증)
- **예상 결과**: invalidAmount 에러

---

## 6. Integration Tests (UseCase + Repository)

#### TC-039: Create 후 Fetch로 확인
- **테스트 목적**: 생성된 지출이 조회 결과에 포함되는지 확인
- **우선순위**: P1
- **Given**: 유효한 ExpenseInput
- **When**:
  1. CreateExpenseUseCase.execute() 호출
  2. FetchTravelExpenseUseCase.execute() 호출
- **Then**: 생성된 지출이 조회 결과에 포함됨
- **예상 결과**: 생성된 지출 포함

#### TC-040: Update 후 Fetch로 확인
- **테스트 목적**: 수정된 지출 정보가 조회 결과에 반영되는지 확인
- **우선순위**: P1
- **Given**: 기존 지출 존재
- **When**:
  1. UpdateExpenseUseCase.execute() 호출
  2. FetchTravelExpenseUseCase.execute() 호출
- **Then**: 수정된 내용이 조회 결과에 반영됨
- **예상 결과**: 수정 내용 반영

#### TC-041: Delete 후 Fetch로 확인
- **테스트 목적**: 삭제된 지출이 조회 결과에서 제외되는지 확인
- **우선순위**: P1
- **Given**: 기존 지출 존재
- **When**:
  1. DeleteExpenseUseCase.execute() 호출
  2. FetchTravelExpenseUseCase.execute() 호출
- **Then**: 삭제된 지출이 조회 결과에서 제외됨
- **예상 결과**: 삭제된 지출 미포함

---

## Test Priority Summary

### P0 (Critical - 반드시 구현)
| TC ID | UseCase | 설명 |
|-------|---------|------|
| TC-001 | Create | 유효한 입력으로 지출 생성 성공 |
| TC-008 | Create | 금액이 음수인 경우 |
| TC-009 | Create | 금액이 0인 경우 |
| TC-010 | Create | 제목이 빈 문자열인 경우 |
| TC-011 | Create | 제목이 공백만 있는 경우 |
| TC-012 | Create | 참가자가 없는 경우 |
| TC-013 | Create | 지불자가 참가자 목록에 없는 경우 |
| TC-015 | Delete | 존재하는 지출 삭제 성공 |
| TC-019 | Fetch | 지출 목록 조회 성공 (날짜 필터 없음) |
| TC-020 | Fetch | 특정 날짜의 지출만 조회 |
| TC-026 | Update | 지출 정보 수정 성공 |
| TC-032 | Update | 수정 시 금액을 음수로 변경 |
| TC-033 | Update | 수정 시 제목을 빈 문자열로 변경 |
| TC-034 | Update | 수정 시 참가자를 빈 배열로 변경 |
| TC-035 | Update | 수정 시 지불자를 참가자에서 제외 |
| TC-037 | Validation | ExpenseInput - 모든 필드 유효 |

### P1 (Important - 권장)
| TC ID | UseCase | 설명 |
|-------|---------|------|
| TC-002 | Create | 다양한 카테고리로 지출 생성 성공 |
| TC-004 | Create | 참가자가 1명인 경우 |
| TC-014 | Create | Repository 저장 실패 시 |
| TC-017 | Delete | 존재하지 않는 expenseId로 삭제 시도 |
| TC-018 | Delete | Repository 삭제 실패 시 |
| TC-021 | Fetch | 빈 지출 목록 조회 |
| TC-022 | Fetch | 해당 날짜에 지출이 없는 경우 |
| TC-023 | Fetch | AsyncStream이 여러 번 yield하는 경우 |
| TC-025 | Fetch | Repository 조회 실패 시 |
| TC-027 | Update | 제목만 수정 |
| TC-028 | Update | 금액만 수정 |
| TC-029 | Update | 참가자 변경 |
| TC-030 | Update | 지불자 변경 |
| TC-036 | Update | Repository 수정 실패 시 |
| TC-039 | Integration | Create 후 Fetch로 확인 |
| TC-040 | Integration | Update 후 Fetch로 확인 |
| TC-041 | Integration | Delete 후 Fetch로 확인 |

### P2 (Nice to have)
| TC ID | UseCase | 설명 |
|-------|---------|------|
| TC-003 | Create | 금액이 0.01인 경우 (최소 양수) |
| TC-005 | Create | 금액이 매우 큰 경우 |
| TC-006 | Create | 제목에 특수문자 포함 |
| TC-007 | Create | 참가자가 다수인 경우 (10명 이상) |
| TC-016 | Delete | 빈 expenseId로 삭제 시도 |
| TC-024 | Fetch | 날짜 경계값 테스트 (자정 기준) |
| TC-031 | Update | 동일한 값으로 수정 (변경 없음) |
| TC-038 | Validation | 금액 검증 우선순위 확인 |

---

## Implementation Notes

### Mock 설정 필요사항
1. **MockExpenseRepository 확장 필요**:
   - `setShouldFailDelete(_ value: Bool)` 메서드 추가
   - 빈 배열 반환 설정 메서드 추가
   - 여러 번 yield 시뮬레이션 지원

2. **기존 테스트 파일 수정 필요**:
   - `ExpenseValidationTests.swift`의 Expense 생성자 업데이트
   - `payerId`/`payerName` -> `payer: TravelMember` 변경

### 테스트 파일 구조 제안
```
Domain/Tests/
├── Reports/
│   └── TestPlan.md (현재 문서)
├── UseCase/
│   └── Expense/
│       ├── CreateExpenseUseCaseTests.swift
│       ├── DeleteExpenseUseCaseTests.swift
│       ├── FetchTravelExpenseUseCaseTests.swift
│       └── UpdateExpenseUseCaseTests.swift
├── Entity/
│   └── Expense/
│       └── ExpenseInputValidationTests.swift
├── Integration/
│   └── ExpenseIntegrationTests.swift
└── ExpenseValidationTests.swift (기존 - 업데이트 필요)
```

### TCA Dependencies 테스트 패턴
```swift
import Testing
import Dependencies
@testable import Domain

@Suite("CreateExpenseUseCase Tests")
struct CreateExpenseUseCaseTests {
    @Test("TC-001: 유효한 입력으로 지출 생성 성공")
    func createExpenseSuccess() async throws {
        let mockRepository = MockExpenseRepository()

        try await withDependencies {
            $0.expenseRepository = mockRepository
        } operation: {
            let useCase = CreateExpenseUseCase()
            let input = ExpenseInput(
                title: "점심 식사",
                amount: 50000.0,
                currency: "KRW",
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                participantIds: ["user1", "user2", "user3"]
            )

            try await useCase.execute(travelId: "travel-123", input: input)

            // Verify repository was called
            let savedExpense = await mockRepository.fetch(id: "user1")
            #expect(savedExpense != nil)
        }
    }
}
```

---

## Revision History

| 버전 | 날짜 | 작성자 | 변경 내용 |
|------|------|--------|----------|
| 1.0 | 2026-01-29 | Claude | 초기 작성 |
