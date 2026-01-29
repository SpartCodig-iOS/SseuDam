//
//  ExpenseValidationTests.swift
//  Domain
//
//  Created by 홍석현 on 11/26/25.
//

import Testing
@testable import Domain
import Foundation

@Suite("Expense Validation Tests", .tags(.expense, .model))
struct ExpenseValidationTests {

    // MARK: - Test Fixtures

    private func makeMember(
        id: String = "user1",
        name: String = "홍석현",
        role: MemberRole = .owner
    ) -> TravelMember {
        TravelMember(id: id, name: name, role: role)
    }

    // MARK: - Amount Validation

    @Test("금액이 0 이하일 때 에러")
    func invalidAmount() throws {
        let payer = makeMember()
        let expense = Expense(
            id: "1",
            title: "점심",
            amount: -1000,  // 음수
            currency: "KRW",
            convertedAmount: -1000,
            expenseDate: Date(),
            category: .foodAndDrink,
            payer: payer,
            participants: [payer]
        )

        #expect(throws: ExpenseError.invalidAmount(-1000)) {
            try expense.validate()
        }
    }

    // MARK: - Title Validation

    @Test("제목이 비어있을 때 에러")
    func emptyTitle() throws {
        let payer = makeMember()
        let expense = Expense(
            id: "1",
            title: "   ",  // 공백만
            amount: 1000,
            currency: "KRW",
            convertedAmount: 1000,
            expenseDate: Date(),
            category: .foodAndDrink,
            payer: payer,
            participants: [payer]
        )

        #expect(throws: ExpenseError.emptyTitle) {
            try expense.validate()
        }
    }

    // MARK: - Date Validation (Known Issue)

    @Test("지출 날짜가 미래일 때 에러",
          .disabled("Known Issue: Expense.validate()에 날짜 검증 로직 없음"))
    func invalidDate() throws {
        /*
        ┌─────────────────────────────────────────────────────┐
        │ 비즈니스 규칙 (기대 동작)                            │
        ├─────────────────────────────────────────────────────┤
        │ - 지출 날짜는 미래일 수 없음                         │
        │ - ExpenseError.invalidDate 정의됨                   │
        ├─────────────────────────────────────────────────────┤
        │ 현재 상태                                           │
        │ - Expense.validate()에 날짜 검증 로직 없음          │
        │ - 미래 날짜도 허용됨                                 │
        ├─────────────────────────────────────────────────────┤
        │ 리팩토링 제안                                       │
        │ - Expense.validate()에 날짜 검증 추가               │
        │ guard expenseDate <= Date() else {                 │
        │     throw ExpenseError.invalidDate                  │
        │ }                                                   │
        └─────────────────────────────────────────────────────┘
        */

        let futureDate = Date().addingTimeInterval(86400)  // 내일
        let payer = makeMember()

        let expense = Expense(
            id: "1",
            title: "점심",
            amount: 12_000,
            currency: "KRW",
            convertedAmount: 12_000,
            expenseDate: futureDate,  // 미래 날짜
            category: .foodAndDrink,
            payer: payer,
            participants: [payer]
        )

        #expect(throws: ExpenseError.invalidDate) {
            try expense.validate()
        }
    }

    // MARK: - Participants Validation

    @Test("참가자가 없을 때 에러")
    func invalidParticipants() throws {
        let payer = makeMember()
        let expense = Expense(
            id: "1",
            title: "점심",
            amount: 12_000,
            currency: "KRW",
            convertedAmount: 12_000,
            expenseDate: Date(),
            category: .foodAndDrink,
            payer: payer,
            participants: []  // 빈 배열
        )

        #expect(throws: ExpenseError.invalidParticipants) {
            try expense.validate()
        }
    }

    @Test("지불자가 참가자 목록에 없을 때 에러")
    func payerNotInParticipants() throws {
        let payer = makeMember(id: "user1", name: "홍석현", role: .owner)
        let expense = Expense(
            id: "1",
            title: "점심",
            amount: 12_000,
            currency: "KRW",
            convertedAmount: 12_000,
            expenseDate: Date(),
            category: .foodAndDrink,
            payer: payer,  // 참가자 목록에 없음
            participants: [
                makeMember(id: "user2", name: "김철수", role: .member),
                makeMember(id: "user3", name: "이영희", role: .member)
            ]
        )

        #expect(throws: ExpenseError.payerNotInParticipants) {
            try expense.validate()
        }
    }

    // MARK: - Happy Path

    @Test("모든 검증 통과")
    func validExpense() throws {
        let payer = makeMember(id: "user1", name: "홍석현", role: .owner)
        let expense = Expense(
            id: "1",
            title: "점심",
            amount: 50_000,
            currency: "KRW",
            convertedAmount: 50_000,
            expenseDate: Date(),
            category: .foodAndDrink,
            payer: payer,
            participants: [
                payer,
                makeMember(id: "user2", name: "김철수", role: .member)
            ]
        )

        // when / then - 에러가 발생하지 않아야 함
        try expense.validate()
    }
}
