//
//  CalculateSettlementUseCaseProtocol.swift
//  Domain
//
//  Created by 홍석현 on 12/10/25.
//

import Foundation

// 정산 계산 결과
public struct SettlementCalculation: Equatable {
    public let totalExpenseAmount: Double // 총 지출 금액
    public let myShareAmount: Double // 내가 부담해야 할 금액 (내가 참여한 지출들의 분담금 합계)
    public let totalPersonCount: Int // 인원수
    public let averagePerPerson: Double // 1인 평균 지출
    public let myNetBalance: Double // 내 순 차액 (Pay - Owe)
    public let memberBalances: [String: Double] // 각 멤버의 순 차액
    public let paymentsToMake: [PaymentInfo] // 지급 예정 금액
    public let paymentsToReceive: [PaymentInfo] // 수령 예정 금액

    public init(
        totalExpenseAmount: Double,
        myShareAmount: Double,
        totalPersonCount: Int,
        averagePerPerson: Double,
        myNetBalance: Double,
        memberBalances: [String: Double],
        paymentsToMake: [PaymentInfo],
        paymentsToReceive: [PaymentInfo]
    ) {
        self.totalExpenseAmount = totalExpenseAmount
        self.myShareAmount = myShareAmount
        self.totalPersonCount = totalPersonCount
        self.averagePerPerson = averagePerPerson
        self.myNetBalance = myNetBalance
        self.memberBalances = memberBalances
        self.paymentsToMake = paymentsToMake
        self.paymentsToReceive = paymentsToReceive
    }
}

// 지급/수령 정보
public struct PaymentInfo: Equatable, Identifiable {
    public let id: String
    public let memberId: String
    public let memberName: String
    public let amount: Double

    public init(
        id: String,
        memberId: String,
        memberName: String,
        amount: Double
    ) {
        self.id = id
        self.memberId = memberId
        self.memberName = memberName
        self.amount = amount
    }
}

public protocol CalculateSettlementUseCaseProtocol {
    func execute(
        expenses: [Expense],
        members: [TravelMember],
        currentUserId: String?
    ) -> SettlementCalculation
}
