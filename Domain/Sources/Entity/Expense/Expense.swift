//
//  Expense.swift
//  Domain
//
//  Created by 홍석현 on 11/21/25.
//

import Foundation

public struct Expense: Identifiable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let amount: Double
    public let currency: String
    public let convertedAmount: Double // 환산 금액
    public let expenseDate: Date
    public let category: ExpenseCategory
    public let payer: TravelMember
    public let participants: [TravelMember]
    public init(
        id: String,
        title: String,
        amount: Double,
        currency: String,
        convertedAmount: Double,
        expenseDate: Date,
        category: ExpenseCategory,
        payer: TravelMember,
        participants: [TravelMember]
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.currency = currency
        self.convertedAmount = convertedAmount
        self.expenseDate = expenseDate
        self.category = category
        self.payer = payer
        self.participants = participants
    }
}

// MARK: - Validation
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

        // 참가자 검증
        guard !participants.isEmpty else {
            throw ExpenseError.invalidParticipants
        }

        // 지불자가 참가자 목록에 있는지 검증
        guard participants.contains(where: { $0.id == payer.id }) else {
            throw ExpenseError.payerNotInParticipants
        }
    }
}

// MARK: - Helper
extension Expense {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    public func formatExpenseDate() -> String {
        Self.dateFormatter.string(from: expenseDate)
    }

    public static func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    public static func parseDate(_ dateString: String) -> Date? {
        dateFormatter.date(from: dateString)
    }

    /// convertedAmount를 포맷팅 (소수점 제거)
    public func formattedConvertedAmount() -> String {
        convertedAmount.formatted(.number.precision(.fractionLength(0)))
    }

    /// amount를 포맷팅 (소수점 제거)
    public func formattedAmount() -> String {
        amount.formatted(.number.precision(.fractionLength(0)))
    }
}

// MARK: - Mock Data
extension Expense {
    public static let mockMembers = [
        TravelMember(id: "user1", name: "김민수", role: .owner),
        TravelMember(id: "user2", name: "이지은", role: .member),
        TravelMember(id: "user3", name: "박서준", role: .member)
    ]

    public static let mock1 = Expense(
        id: "expense1",
        title: "오사카 호텔 숙박",
        amount: 45000,
        currency: "JPY",
        convertedAmount: 405000,
        expenseDate: Date().addingTimeInterval(-86400 * 2),
        category: .accommodation,
        payer: mockMembers[0],
        participants: mockMembers
    )

    public static let mock2 = Expense(
        id: "expense2",
        title: "라멘 맛집 점심",
        amount: 3600,
        currency: "JPY",
        convertedAmount: 32400,
        expenseDate: Date().addingTimeInterval(-86400),
        category: .foodAndDrink,
        payer: mockMembers[1],
        participants: mockMembers
    )

    public static let mock3 = Expense(
        id: "expense3",
        title: "유니버셜 스튜디오 입장권",
        amount: 27000,
        currency: "JPY",
        convertedAmount: 243000,
        expenseDate: Date().addingTimeInterval(-86400),
        category: .activity,
        payer: mockMembers[0],
        participants: mockMembers
    )

    public static let mock4 = Expense(
        id: "expense4",
        title: "오사카역 택시",
        amount: 2500,
        currency: "JPY",
        convertedAmount: 22500,
        expenseDate: Date().addingTimeInterval(-3600),
        category: .transportation,
        payer: mockMembers[2],
        participants: mockMembers
    )

    public static let mock5 = Expense(
        id: "expense5",
        title: "기념품 쇼핑",
        amount: 15000,
        currency: "JPY",
        convertedAmount: 135000,
        expenseDate: Date(),
        category: .shopping,
        payer: mockMembers[1],
        participants: [mockMembers[0], mockMembers[1]]
    )

    public static let mock6 = Expense(
        id: "expense6",
        title: "편의점 간식",
        amount: 1200,
        currency: "JPY",
        convertedAmount: 10800,
        expenseDate: Date().addingTimeInterval(-86400 * 2 + 3600), // 2일 전
        category: .foodAndDrink,
        payer: mockMembers[0],
        participants: mockMembers
    )

    public static let mock7 = Expense(
        id: "expense7",
        title: "지하철 패스",
        amount: 2000,
        currency: "JPY",
        convertedAmount: 18000,
        expenseDate: Date().addingTimeInterval(-86400 * 2 - 3600), // 2일 전
        category: .transportation,
        payer: mockMembers[1],
        participants: mockMembers
    )

    public static let mock8 = Expense(
        id: "expense8",
        title: "규카츠 저녁",
        amount: 4500,
        currency: "JPY",
        convertedAmount: 40500,
        expenseDate: Date().addingTimeInterval(-86400), // 1일 전
        category: .foodAndDrink,
        payer: mockMembers[2],
        participants: mockMembers
    )

    public static let mock9 = Expense(
        id: "expense9",
        title: "카페",
        amount: 1500,
        currency: "JPY",
        convertedAmount: 13500,
        expenseDate: Date().addingTimeInterval(-3600 * 2), // 오늘
        category: .foodAndDrink,
        payer: mockMembers[0],
        participants: [mockMembers[0], mockMembers[1]]
    )

    public static let mock10 = Expense(
        id: "expense10",
        title: "공항 버스",
        amount: 3200,
        currency: "JPY",
        convertedAmount: 28800,
        expenseDate: Date().addingTimeInterval(3600), // 오늘 (미래?) -> 테스트용으로 오늘로 간주
        category: .transportation,
        payer: mockMembers[1],
        participants: mockMembers
    )

    public static let mockList = [mock1, mock2, mock3, mock4, mock5, mock6, mock7, mock8, mock9, mock10]
}
