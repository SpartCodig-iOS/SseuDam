//
//  ExpenseValidationTests.swift
//  Domain
//
//  Created by 홍석현 on 11/26/25.
//

import Testing
@testable import Domain
import Foundation

@Suite("Expense Validation Tests")
struct ExpenseValidationTests {
    
    @Test("금액이 0 이하일 때 에러")
    func invalidAmount() throws {
        let expense = Expense(
            id: "1",
            title: "점심",
            note: nil,
            amount: -1000,  // ❌ 음수
            currency: "KRW",
            convertedAmount: -1000,
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",
            payerName: "홍석현",
            participants: [
                TravelMember(id: "user1", name: "홍석현", role: "owner")
            ]
        )
        
        #expect(throws: ExpenseError.invalidAmount(-1000)) {
            try expense.validate()
        }
    }
    
    @Test("제목이 비어있을 때 에러")
    func emptyTitle() throws {
        let expense = Expense(
            id: "1",
            title: "   ",  // ❌ 공백만
            note: nil,
            amount: 1000,
            currency: "KRW",
            convertedAmount: 1000,
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",
            payerName: "홍석현",
            participants: [
                TravelMember(id: "user1", name: "홍석현", role: "owner")
            ]
        )

        #expect(throws: ExpenseError.emptyTitle) {
            try expense.validate()
        }
    }
    
    @Test("지출 날짜가 미래일 때 에러")
    func invalidDate() throws {
        let futureDate = Date().addingTimeInterval(86400)  // 내일
        
        let expense = Expense(
            id: "1",
            title: "점심",
            note: nil,
            amount: 12_000,
            currency: "KRW",
            convertedAmount: 12_000,
            expenseDate: futureDate,  // ❌ 미래 날짜
            category: .foodAndDrink,
            payerId: "user1",
            payerName: "홍석현",
            participants: [
                TravelMember(id: "user1", name: "홍석현", role: "owner")
            ]
        )
        
        #expect(throws: ExpenseError.invalidDate) {
            try expense.validate()
        }
    }
    
    @Test("참가자가 없을 때 에러")
    func invalidParticipants() throws {
        let expense = Expense(
            id: "1",
            title: "점심",
            note: nil,
            amount: 12_000,
            currency: "KRW",
            convertedAmount: 12_000,
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",
            payerName: "홍석현",
            participants: []  // ❌ 빈 배열
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
            note: nil,
            amount: 12_000,
            currency: "KRW",
            convertedAmount: 12_000,
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",  // ❌ 참가자 목록에 없음
            payerName: "홍석현",
            participants: [
                TravelMember(id: "user2", name: "김철수", role: "member"),
                TravelMember(id: "user3", name: "이영희", role: "member")
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
            note: "회식",
            amount: 50_000,
            currency: "KRW",
            convertedAmount: 50_000,
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",
            payerName: "홍석현",
            participants: [
                TravelMember(id: "user1", name: "홍석현", role: "owner"),
                TravelMember(id: "user2", name: "김철수", role: "member")
            ]
        )
        
        // when / then - 에러가 발생하지 않아야 함
        try expense.validate()
    }
}
