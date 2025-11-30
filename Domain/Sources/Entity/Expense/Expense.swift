//
//  Expense.swift
//  Domain
//
//  Created by 홍석현 on 11/21/25.
//

import Foundation

public struct Expense: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let note: String?
    public let amount: Double
    public let currency: String
    public let convertedAmount: Double // 환산 금액
    public let expenseDate: Date
    public let category: ExpenseCategory
    public let payerId: String
    public let payerName: String
    public let participants: [TravelMember]
    public init(
        id: String,
        title: String,
        note: String?,
        amount: Double,
        currency: String,
        convertedAmount: Double,
        expenseDate: Date,
        category: ExpenseCategory,
        payerId: String,
        payerName: String,
        participants: [TravelMember]
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.amount = amount
        self.currency = currency
        self.convertedAmount = convertedAmount
        self.expenseDate = expenseDate
        self.category = category
        self.payerId = payerId
        self.payerName = payerName
        self.participants = participants
    }
}

extension Expense {
    public func validate() throws {
        // 금액 검증
        guard amount > 0 else {
            throw ExpenseError.invalidAmount(amount)
        }

        // 제목 검증
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ExpenseError.emptyTitle
        }

        // 날짜 검증
        guard expenseDate <= Date() else {
            throw ExpenseError.invalidDate
        }

        // 참가자 검증
        guard !participants.isEmpty else {
            throw ExpenseError.invalidParticipants
        }

        // 지불자가 참가자 목록에 있는지 검증
        guard participants.contains(where: { $0.id == payerId }) else {
            throw ExpenseError.payerNotInParticipants
        }
    }
}

// MARK: - Mock Data
extension Expense {
    public static let mockMembers = [
        TravelMember(id: "user1", name: "김민수", role: "owner"),
        TravelMember(id: "user2", name: "이지은", role: "member"),
        TravelMember(id: "user3", name: "박서준", role: "member")
    ]

    public static let mock1 = Expense(
        id: "expense1",
        title: "오사카 호텔 숙박",
        note: "3박 4일 숙박비",
        amount: 45000,
        currency: "JPY",
        convertedAmount: 405000,
        expenseDate: Date().addingTimeInterval(-86400 * 2),
        category: .accommodation,
        payerId: "user1",
        payerName: "김민수",
        participants: mockMembers
    )

    public static let mock2 = Expense(
        id: "expense2",
        title: "라멘 맛집 점심",
        note: "이치란 라멘",
        amount: 3600,
        currency: "JPY",
        convertedAmount: 32400,
        expenseDate: Date().addingTimeInterval(-86400),
        category: .foodAndDrink,
        payerId: "user2",
        payerName: "이지은",
        participants: mockMembers
    )

    public static let mock3 = Expense(
        id: "expense3",
        title: "유니버셜 스튜디오 입장권",
        note: nil,
        amount: 27000,
        currency: "JPY",
        convertedAmount: 243000,
        expenseDate: Date().addingTimeInterval(-86400),
        category: .activity,
        payerId: "user1",
        payerName: "김민수",
        participants: mockMembers
    )

    public static let mock4 = Expense(
        id: "expense4",
        title: "오사카역 택시",
        note: "호텔까지 택시 요금",
        amount: 2500,
        currency: "JPY",
        convertedAmount: 22500,
        expenseDate: Date().addingTimeInterval(-3600),
        category: .transportation,
        payerId: "user3",
        payerName: "박서준",
        participants: mockMembers
    )

    public static let mock5 = Expense(
        id: "expense5",
        title: "기념품 쇼핑",
        note: "키타 오사카 쇼핑몰",
        amount: 15000,
        currency: "JPY",
        convertedAmount: 135000,
        expenseDate: Date(),
        category: .shopping,
        payerId: "user2",
        payerName: "이지은",
        participants: [mockMembers[0], mockMembers[1]]
    )

    public static let mockList = [mock1, mock2, mock3, mock4, mock5]
}
