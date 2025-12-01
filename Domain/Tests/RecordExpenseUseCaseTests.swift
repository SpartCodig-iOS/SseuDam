//
//  RecordExpenseUseCaseTests.swift
//  DomainTests
//
//  Created by 홍석현 on 11/25/25.
//

import Foundation
import Testing
@testable import Domain

struct RecordExpenseUseCaseTests {
    @Test("지출 기록 성공")
    func recordExpenseSuccess() async throws {
        let repository = MockExpenseRepository()
        let useCase = RecordExpenseUseCase(repository: repository)
        let id = "123"
        let expense = Expense(
            id: id,
            title: "점심",
            note: nil,
            amount: 12_000,
            currency: "KRW",
            convertedAmount: 12_000,
            expenseDate: Date(),
            category: .foodAndDrink,
            payerId: "user1",
            payerName: "홍석현",
            participants: [
                TravelMember(id: "user1", name: "홍석현", role: "owner")
            ]
        )
        
        try await useCase.execute(expense: expense)
        let saved = await repository.fetch(id: id)
        #expect(saved?.title == "점심")
    }
}
