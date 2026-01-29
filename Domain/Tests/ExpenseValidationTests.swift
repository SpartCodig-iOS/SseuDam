//
//  ExpenseValidationTests.swift
//  Domain
//
//  Created by 홍석현 on 11/26/25.
//

import Testing
@testable import Domain
import Foundation

@Suite("Expense Validation Tests", .tags(.unit, .expense))
struct ExpenseValidationTests {

    // MARK: - Test Data

    private var payer: TravelMember {
        TravelMember(id: "user1", name: "홍석현", role: .owner)
    }

    private var participants: [TravelMember] {
        [
            TravelMember(id: "user1", name: "홍석현", role: .owner),
            TravelMember(id: "user2", name: "김철수", role: .member)
        ]
    }

    // MARK: - Expense Entity Validation Tests

    @Test("금액이 0 이하일 때 에러")
    func invalidAmount() throws {
        let expense = Expense(
            id: "1",
            title: "점심",
            amount: -1000,
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

    @Test("제목이 비어있을 때 에러")
    func emptyTitle() throws {
        let expense = Expense(
            id: "1",
            title: "   ",
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

    @Test("참가자가 없을 때 에러")
    func invalidParticipants() throws {
        let expense = Expense(
            id: "1",
            title: "점심",
            amount: 12_000,
            currency: "KRW",
            convertedAmount: 12_000,
            expenseDate: Date(),
            category: .foodAndDrink,
            payer: payer,
            participants: []
        )

        #expect(throws: ExpenseError.invalidParticipants) {
            try expense.validate()
        }
    }

    @Test("지불자가 참가자 목록에 없을 때 에러")
    func payerNotInParticipants() throws {
        let expense = Expense(
            id: "1",
            title: "점심",
            amount: 12_000,
            currency: "KRW",
            convertedAmount: 12_000,
            expenseDate: Date(),
            category: .foodAndDrink,
            payer: payer,
            participants: [
                TravelMember(id: "user2", name: "김철수", role: .member),
                TravelMember(id: "user3", name: "이영희", role: .member)
            ]
        )

        #expect(throws: ExpenseError.payerNotInParticipants) {
            try expense.validate()
        }
    }

    @Test("모든 검증 통과")
    func validExpense() throws {
        let expense = Expense(
            id: "1",
            title: "점심",
            amount: 50_000,
            currency: "KRW",
            convertedAmount: 50_000,
            expenseDate: Date(),
            category: .foodAndDrink,
            payer: payer,
            participants: participants
        )

        // when / then - 에러가 발생하지 않아야 함
        try expense.validate()
    }

    // MARK: - ExpenseInput Validation Tests (TC-037, TC-038)

    @Test("TC-037: ExpenseInput - 모든 필드 유효")
    func validExpenseInput() throws {
        let input = ExpenseInput(
            title: "점심 식사",
            amount: 50000.0,
            currency: "KRW",
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",
            participantIds: ["user1", "user2", "user3"]
        )

        // when / then - 에러가 발생하지 않아야 함
        try input.validate()
    }

    @Test("TC-038: ExpenseInput - 금액 검증 우선순위 확인")
    func validationPriority_amountFirst() throws {
        // Given - 여러 유효하지 않은 필드: 금액 음수, 제목 비어있음, 참가자 없음
        let input = ExpenseInput(
            title: "",
            amount: -1000.0,
            currency: "KRW",
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",
            participantIds: []
        )

        // When / Then - 금액 검증이 먼저 실행되어 invalidAmount 에러가 발생해야 함
        #expect(throws: ExpenseError.invalidAmount(-1000.0)) {
            try input.validate()
        }
    }

    @Test("ExpenseInput - 금액이 0인 경우")
    func expenseInput_zeroAmount() throws {
        let input = ExpenseInput(
            title: "테스트",
            amount: 0.0,
            currency: "KRW",
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",
            participantIds: ["user1"]
        )

        #expect(throws: ExpenseError.invalidAmount(0.0)) {
            try input.validate()
        }
    }

    @Test("ExpenseInput - 제목이 빈 문자열인 경우")
    func expenseInput_emptyTitle() throws {
        let input = ExpenseInput(
            title: "",
            amount: 10000.0,
            currency: "KRW",
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",
            participantIds: ["user1"]
        )

        #expect(throws: ExpenseError.emptyTitle) {
            try input.validate()
        }
    }

    @Test("ExpenseInput - 제목이 공백만 있는 경우")
    func expenseInput_whitespaceOnlyTitle() throws {
        let input = ExpenseInput(
            title: "   ",
            amount: 10000.0,
            currency: "KRW",
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",
            participantIds: ["user1"]
        )

        #expect(throws: ExpenseError.emptyTitle) {
            try input.validate()
        }
    }

    @Test("ExpenseInput - 참가자가 없는 경우")
    func expenseInput_emptyParticipants() throws {
        let input = ExpenseInput(
            title: "테스트",
            amount: 10000.0,
            currency: "KRW",
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",
            participantIds: []
        )

        #expect(throws: ExpenseError.invalidParticipants) {
            try input.validate()
        }
    }

    @Test("ExpenseInput - 지불자가 참가자 목록에 없는 경우")
    func expenseInput_payerNotInParticipants() throws {
        let input = ExpenseInput(
            title: "테스트",
            amount: 10000.0,
            currency: "KRW",
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",
            participantIds: ["user2", "user3"]
        )

        #expect(throws: ExpenseError.payerNotInParticipants) {
            try input.validate()
        }
    }

    @Test("ExpenseInput - 최소 유효 금액 (0.01)")
    func expenseInput_minimumValidAmount() throws {
        let input = ExpenseInput(
            title: "최소 금액",
            amount: 0.01,
            currency: "KRW",
            expenseDate: Date(),
            category: .other,
            payerId: "user1",
            participantIds: ["user1"]
        )

        // 에러가 발생하지 않아야 함
        try input.validate()
    }

    @Test("ExpenseInput - 매우 큰 금액")
    func expenseInput_veryLargeAmount() throws {
        let input = ExpenseInput(
            title: "대용량 금액",
            amount: 999_999_999.99,
            currency: "KRW",
            expenseDate: Date(),
            category: .accommodation,
            payerId: "user1",
            participantIds: ["user1"]
        )

        // 에러가 발생하지 않아야 함
        try input.validate()
    }
}
