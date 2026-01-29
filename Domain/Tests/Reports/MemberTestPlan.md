# Member Domain Test Plan

## 개요
Member 도메인의 5개 UseCase에 대한 테스트 계획입니다.

| 항목 | 내용 |
|------|------|
| 작성자 | 홍석현 |
| 작성일 | 2026-01-29 |
| 대상 모듈 | Domain/UseCase/Travel/Member |
| 테스트 프레임워크 | Swift Testing |

---

## UseCase 목록

| # | UseCase | Input | Output | 의존성 |
|---|---------|-------|--------|--------|
| 1 | FetchMemberUseCase | travelId: String | MyTravelMember | TravelMemberRepositoryProtocol |
| 2 | DeleteTravelMemberUseCase | travelId: String, memberId: String | Void | TravelMemberRepositoryProtocol |
| 3 | DelegateOwnerUseCase | travelId: String, newOwnerId: String | Travel | TravelMemberRepositoryProtocol |
| 4 | JoinTravelUseCase | inviteCode: String | Travel | TravelMemberRepositoryProtocol |
| 5 | LeaveTravelUseCase | travelId: String | Void | TravelMemberRepositoryProtocol |

---

## Entity 구조

### TravelMember
```swift
struct TravelMember {
    let id: String
    let name: String
    let role: MemberRole
    let email: String?
    let avatarUrl: String?
}
```

### MyTravelMember
```swift
struct MyTravelMember {
    let myInfo: TravelMember
    let memberInfo: [TravelMember]
}
```

### MemberRole
```swift
enum MemberRole: String {
    case owner = "owner"
    case member = "member"
}
```

---

## Test Cases

### 1. FetchMemberUseCase Tests

| TC ID | 우선순위 | 테스트 설명 | 입력 | 예상 결과 |
|-------|----------|-------------|------|-----------|
| TC-MEMBER-001 | P0 | 유효한 travelId로 멤버 조회 성공 | travelId: "MOCK-1" | myInfo 존재, memberInfo 배열 반환 |
| TC-MEMBER-002 | P0 | 존재하지 않는 travelId로 조회 시 에러 | travelId: "INVALID" | throws Error (404) |
| TC-MEMBER-003 | P1 | myInfo가 owner 역할인지 확인 | travelId: "MOCK-1" | myInfo.role == .owner |
| TC-MEMBER-004 | P1 | 빈 문자열 travelId로 조회 시 에러 | travelId: "" | throws Error |

### 2. DeleteTravelMemberUseCase Tests

| TC ID | 우선순위 | 테스트 설명 | 입력 | 예상 결과 |
|-------|----------|-------------|------|-----------|
| TC-MEMBER-010 | P0 | 유효한 memberId로 멤버 삭제 성공 | travelId: "MOCK-1", memberId: "MOCKmember-1" | 성공 (no throw) |
| TC-MEMBER-011 | P0 | 존재하지 않는 travelId로 삭제 시 에러 | travelId: "INVALID", memberId: "any" | throws Error (404) |
| TC-MEMBER-012 | P1 | 존재하지 않는 memberId로 삭제 시 | travelId: "MOCK-1", memberId: "INVALID" | 성공 (멤버가 없어도 에러 없음) |
| TC-MEMBER-013 | P1 | 빈 문자열 파라미터로 삭제 시 | travelId: "", memberId: "" | 동작 확인 |

### 3. DelegateOwnerUseCase Tests

| TC ID | 우선순위 | 테스트 설명 | 입력 | 예상 결과 |
|-------|----------|-------------|------|-----------|
| TC-MEMBER-020 | P0 | 유효한 newOwnerId로 권한 위임 성공 | travelId: "MOCK-1", newOwnerId: "MOCKmember-1" | Travel 반환, ownerName 변경됨 |
| TC-MEMBER-021 | P0 | 존재하지 않는 travelId로 위임 시 에러 | travelId: "INVALID", newOwnerId: "any" | throws Error (404) |
| TC-MEMBER-022 | P1 | 존재하지 않는 newOwnerId로 위임 시 | travelId: "MOCK-1", newOwnerId: "INVALID" | Travel 반환 (기존 ownerName 유지) |
| TC-MEMBER-023 | P1 | 권한 위임 후 반환된 Travel 정보 검증 | travelId: "MOCK-1", newOwnerId: "MOCKmember-1" | Travel.id, title 등 유지 |

### 4. JoinTravelUseCase Tests

| TC ID | 우선순위 | 테스트 설명 | 입력 | 예상 결과 |
|-------|----------|-------------|------|-----------|
| TC-MEMBER-030 | P0 | 유효한 초대코드로 여행 참여 성공 | inviteCode: "INV-0001" | Travel 반환, 멤버 추가됨 |
| TC-MEMBER-031 | P0 | 잘못된 초대코드로 참여 시 에러 | inviteCode: "INVALID" | throws Error (404) |
| TC-MEMBER-032 | P1 | 참여 후 멤버 수 증가 확인 | inviteCode: "INV-0002" | members.count 증가 |
| TC-MEMBER-033 | P1 | 빈 초대코드로 참여 시 에러 | inviteCode: "" | throws Error |
| TC-MEMBER-034 | P2 | 다양한 형식의 초대코드 테스트 | 여러 inviteCode | 형식에 따른 결과 |

### 5. LeaveTravelUseCase Tests

| TC ID | 우선순위 | 테스트 설명 | 입력 | 예상 결과 |
|-------|----------|-------------|------|-----------|
| TC-MEMBER-040 | P0 | 유효한 travelId로 여행 탈퇴 성공 | travelId: "MOCK-1" | 성공 (no throw) |
| TC-MEMBER-041 | P0 | 존재하지 않는 travelId로 탈퇴 시 에러 | travelId: "INVALID" | throws Error (404) |
| TC-MEMBER-042 | P1 | 빈 문자열 travelId로 탈퇴 시 | travelId: "" | 동작 확인 |
| TC-MEMBER-043 | P1 | 여러 번 탈퇴 시도 | travelId: "MOCK-1" (2회) | 2회 모두 성공 |

---

## 테스트 파일 구조

```
Domain/Tests/
├── Reports/
│   └── MemberTestPlan.md
├── TestTags.swift (기존 - member 태그 추가 필요)
└── UseCase/
    └── Member/
        ├── FetchMemberUseCaseTests.swift
        ├── DeleteTravelMemberUseCaseTests.swift
        ├── DelegateOwnerUseCaseTests.swift
        ├── JoinTravelUseCaseTests.swift
        └── LeaveTravelUseCaseTests.swift
```

---

## Mock 구현 현황

### MockTravelMemberRepository
- **상태**: 완전 구현됨
- **초기 데이터**: 25개의 Travel (MOCK-1 ~ MOCK-25)
- **각 Travel의 멤버**: 1명 (MOCKmember-{i})
- **초대코드 형식**: INV-000{i}

### Mock 동작
| 메서드 | 동작 |
|--------|------|
| fetchMember | travelId로 조회, 없으면 404 에러 |
| deleteMember | travelId로 Travel 찾아 memberId 제거 |
| delegateOwner | newOwnerId를 찾아 ownerName 변경 |
| joinTravel | inviteCode로 Travel 찾아 새 멤버 추가 |
| leaveTravel | travelId로 Travel 찾아 본인 제거 |

---

## 테스트 실행

```bash
# 전체 Member 테스트 실행
swift test --filter "Member"

# 특정 UseCase 테스트 실행
swift test --filter "FetchMemberUseCaseTests"

# 태그 기반 실행
swift test --filter "member"
```

---

## 테스트 커버리지 목표

| UseCase | 목표 커버리지 | 예상 TC 수 |
|---------|--------------|-----------|
| FetchMemberUseCase | 100% | 4 |
| DeleteTravelMemberUseCase | 100% | 4 |
| DelegateOwnerUseCase | 100% | 4 |
| JoinTravelUseCase | 100% | 5 |
| LeaveTravelUseCase | 100% | 4 |
| **총계** | **100%** | **21** |

---

## 주의사항

1. **Swift Testing 사용**: XCTest 대신 Swift Testing 프레임워크 사용
2. **태그 사용**: `.tags(.useCase, .member)` 태그 적용
3. **의존성 주입**: `withDependencies`로 Mock 주입
4. **원본 코드 수정 금지**: 테스트 코드만 작성
5. **비동기 테스트**: `async throws` 패턴 사용
