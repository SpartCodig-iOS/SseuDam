//
//  CalculateSettlementUseCaseTests.swift
//  Domain
//
//  Created by 홍석현 on 12/10/25.
//

import Testing
@testable import Domain
import Foundation

@Suite("정산 계산 UseCase 테스트", .tags(.useCase, .settlement))
struct CalculateSettlementUseCaseTests {

    let useCase = CalculateSettlementUseCase()

    // MARK: - Test Data
    let members = [
        TravelMember(id: "user1", name: "홍석현", role: .owner),
        TravelMember(id: "user2", name: "김철수", role: .member),
        TravelMember(id: "user3", name: "이영희", role: .member)
    ]

    // MARK: - Helper
    private func makeExpense(
        id: String,
        title: String,
        amount: Double,
        category: ExpenseCategory,
        payerId: String,
        participants: [TravelMember]
    ) -> Expense {
        let payer = participants.first { $0.id == payerId } ?? members.first { $0.id == payerId }!
        return Expense(
            id: id,
            title: title,
            amount: amount,
            currency: "KRW",
            convertedAmount: amount,
            expenseDate: Date(),
            category: category,
            payer: payer,
            participants: participants
        )
    }

    // MARK: - Tests

    @Test("지출이 없을 때 모든 값이 0")
    func noExpenses() {
        // given
        let expenses: [Expense] = []

        // when
        let result = useCase.execute(
            expenses: expenses,
            currentUserId: "user1"
        )

        // then
        // 지출이 없으면 expenses에서 멤버를 추출할 수 없으므로 인원수도 0
        #expect(result.totalExpenseAmount == 0)
        #expect(result.myShareAmount == 0)
        #expect(result.totalPersonCount == 0)
        #expect(result.averagePerPerson == 0)
        #expect(result.myNetBalance == 0)
        #expect(result.paymentsToMake.isEmpty)
        #expect(result.paymentsToReceive.isEmpty)
        #expect(result.memberDetails.isEmpty)
    }

    @Test("총 지출 금액 계산 - 단일 지출")
    func totalExpenseAmount_singleExpense() {
        // given
        let expenses = [
            makeExpense(id: "1", title: "호텔", amount: 100_000, category: .accommodation, payerId: "user1", participants: members)
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            currentUserId: "user1"
        )

        // then
        #expect(result.totalExpenseAmount == 100_000)
        #expect(Int(result.myShareAmount) == 100_000 / 3)
    }

    @Test("총 지출 금액 계산 - 여러 지출")
    func totalExpenseAmount_multipleExpenses() throws {
        // given
        let expenses = [
            makeExpense(id: "1", title: "호텔", amount: 100_000, category: .accommodation, payerId: "user1", participants: members),
            makeExpense(id: "2", title: "식사", amount: 30_000, category: .foodAndDrink, payerId: "user2", participants: members)
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            currentUserId: "user1"
        )

        // then
        #expect(result.totalExpenseAmount == 130_000)
        let 개인당지불해야할돈 = (100_000 + 30_000) / 3
        #expect(Int(result.myShareAmount) == 개인당지불해야할돈)

        #expect(result.paymentsToReceive.count == 2)
        #expect(result.paymentsToReceive.contains(where: { $0.memberId == "user2" }))
        #expect(result.paymentsToReceive.contains(where: { $0.memberId == "user3" }))
        let 철수에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "김철수" })?.amount)
        #expect(Int(철수에게받을돈) == abs(개인당지불해야할돈 - 30_000))
        let 영희에게받을돈 = try #require(result.paymentsToReceive.first(where: {  $0.memberName == "이영희" })?.amount)
        #expect(Int(영희에게받을돈) == (개인당지불해야할돈))
        #expect(result.paymentsToMake.isEmpty)
    }

    @Test("내 부담 금액 계산 - 모든 지출에 참여")
    func myShareAmount_allExpenses() {
        // given
        let expenses = [
            makeExpense(id: "1", title: "호텔", amount: 90_000, category: .accommodation, payerId: "user1", participants: members),
            makeExpense(id: "2", title: "식사", amount: 30_000, category: .foodAndDrink, payerId: "user2", participants: members)
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            currentUserId: "user1"
        )

        // then
        #expect(result.myShareAmount == 40_000)
    }

    @Test("내 부담 금액 계산 - 일부 지출만 참여")
    func myShareAmount_partialExpenses() {
        // given
        let partialMembers = [
            TravelMember(id: "user2", name: "김철수", role: .member),
            TravelMember(id: "user3", name: "이영희", role: .member)
        ]
        let expenses = [
            makeExpense(id: "1", title: "호텔", amount: 90_000, category: .accommodation, payerId: "user1", participants: members),
            makeExpense(id: "2", title: "식사", amount: 30_000, category: .foodAndDrink, payerId: "user2", participants: partialMembers)
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            currentUserId: "user1"
        )

        // then
        #expect(result.myShareAmount == 30_000)
    }

    @Test("1인 평균 지출 계산")
    func averagePerPerson() {
        // given
        let expenses = [
            makeExpense(id: "1", title: "호텔", amount: 90_000, category: .accommodation, payerId: "user1", participants: members)
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            currentUserId: "user1"
        )

        // then
        #expect(result.averagePerPerson == 30_000)
    }

    @Test("모든 멤버가 균등하게 결제한 경우 - 정산 없음")
    func allMembersPayEqually() {
        // given
        let expenses = [
            makeExpense(id: "1", title: "호텔", amount: 30_000, category: .accommodation, payerId: "user1", participants: members),
            makeExpense(id: "2", title: "식사", amount: 30_000, category: .foodAndDrink, payerId: "user2", participants: members),
            makeExpense(id: "3", title: "교통", amount: 30_000, category: .transportation, payerId: "user3", participants: members)
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            currentUserId: "user1"
        )

        // then
        let 개인당지불해야할돈 = (30_000 * 3) / 3
        #expect(result.totalExpenseAmount == 90_000)
        #expect(Int(result.myShareAmount) == 개인당지불해야할돈)
        #expect(Int(result.myNetBalance) == 0)
        #expect(result.paymentsToMake.isEmpty)
        #expect(result.paymentsToReceive.isEmpty)
    }

    @Test("내가 아무것도 결제하지 않은 경우 - 빚만 있음")
    func iDidNotPayAnything() throws {
        // given
        let expenses = [
            makeExpense(id: "1", title: "호텔", amount: 60_000, category: .accommodation, payerId: "user2", participants: members),
            makeExpense(id: "2", title: "식사", amount: 30_000, category: .foodAndDrink, payerId: "user3", participants: members)
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            currentUserId: "user1"
        )

        // then
        let 개인당지불해야할돈 = (60_000 + 30_000) / 3
        #expect(result.totalExpenseAmount == 90_000)
        #expect(Int(result.myShareAmount) == 개인당지불해야할돈)
        #expect(Int(result.myNetBalance) == -개인당지불해야할돈)

        #expect(result.paymentsToMake.count == 1)
        let 철수에게줄돈 = try #require(result.paymentsToMake.first(where: { $0.memberName == "김철수" })?.amount)
        #expect(Int(철수에게줄돈) == 30_000)

        #expect(result.paymentsToReceive.isEmpty)
    }

    @Test("내가 모든 것을 결제한 경우 - 받을 돈만 있음")
    func iPaidEverything() throws {
        // given
        let expenses = [
            makeExpense(id: "1", title: "호텔", amount: 60_000, category: .accommodation, payerId: "user1", participants: members),
            makeExpense(id: "2", title: "식사", amount: 30_000, category: .foodAndDrink, payerId: "user1", participants: members)
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            currentUserId: "user1"
        )

        // then
        let 개인당지불해야할돈 = (60_000 + 30_000) / 3
        #expect(result.totalExpenseAmount == 90_000)
        #expect(Int(result.myShareAmount) == 개인당지불해야할돈)
        #expect(Int(result.myNetBalance) == 90_000 - 개인당지불해야할돈)

        #expect(result.paymentsToReceive.count == 2)
        let 철수에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "김철수" })?.amount)
        #expect(Int(철수에게받을돈) == 개인당지불해야할돈)
        let 영희에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "이영희" })?.amount)
        #expect(Int(영희에게받을돈) == 개인당지불해야할돈)

        #expect(result.paymentsToMake.isEmpty)

        // memberDetails 검증
        #expect(result.memberDetails.count == 3)

        let myDetail = try #require(result.memberDetails.first(where: { $0.memberId == "user1" }))
        #expect(Int(myDetail.totalPaid) == 90_000)
        #expect(Int(myDetail.totalOwe) == 개인당지불해야할돈)
        #expect(Int(myDetail.netBalance) == 90_000 - 개인당지불해야할돈)
        #expect(myDetail.paidExpenses.count == 2)
        #expect(myDetail.sharedExpenses.count == 2)

        let 철수Detail = try #require(result.memberDetails.first(where: { $0.memberId == "user2" }))
        #expect(철수Detail.totalPaid == 0)
        #expect(Int(철수Detail.totalOwe) == 개인당지불해야할돈)
        #expect(Int(철수Detail.netBalance) == -개인당지불해야할돈)
        #expect(철수Detail.paidExpenses.isEmpty)
        #expect(철수Detail.sharedExpenses.count == 2)

        let 영희Detail = try #require(result.memberDetails.first(where: { $0.memberId == "user3" }))
        #expect(영희Detail.totalPaid == 0)
        #expect(Int(영희Detail.totalOwe) == 개인당지불해야할돈)
        #expect(Int(영희Detail.netBalance) == -개인당지불해야할돈)
        #expect(영희Detail.paidExpenses.isEmpty)
        #expect(영희Detail.sharedExpenses.count == 2)
    }

    @Test("일부 지출에만 참여 - 참여하지 않은 지출은 제외")
    func partialParticipation() throws {
        // given
        let partialMembers = [
            TravelMember(id: "user2", name: "김철수", role: .member),
            TravelMember(id: "user3", name: "이영희", role: .member)
        ]
        let expenses = [
            makeExpense(id: "1", title: "호텔 (3명 모두 참여)", amount: 90_000, category: .accommodation, payerId: "user1", participants: members),
            makeExpense(id: "2", title: "술집 (나는 불참)", amount: 60_000, category: .foodAndDrink, payerId: "user2", participants: partialMembers)
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            currentUserId: "user1"
        )

        // then
        #expect(result.totalExpenseAmount == 150_000)
        #expect(Int(result.myShareAmount) == 30_000)
        #expect(Int(result.myNetBalance) == 60_000)

        #expect(result.paymentsToReceive.count == 1)
        let 영희에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "이영희" })?.amount)
        #expect(Int(영희에게받을돈) == 60_000)

        #expect(result.paymentsToMake.isEmpty)

        // memberDetails 검증
        #expect(result.memberDetails.count == 3)

        let myDetail = try #require(result.memberDetails.first(where: { $0.memberId == "user1" }))
        #expect(Int(myDetail.totalPaid) == 90_000)
        #expect(Int(myDetail.totalOwe) == 30_000)
        #expect(Int(myDetail.netBalance) == 60_000)
        #expect(myDetail.paidExpenses.count == 1)
        #expect(myDetail.sharedExpenses.count == 1)

        let 철수Detail = try #require(result.memberDetails.first(where: { $0.memberId == "user2" }))
        #expect(Int(철수Detail.totalPaid) == 60_000)
        #expect(Int(철수Detail.totalOwe) == 60_000)
        #expect(Int(철수Detail.netBalance) == 0)
        #expect(철수Detail.paidExpenses.count == 1)
        #expect(철수Detail.sharedExpenses.count == 2)

        let 영희Detail = try #require(result.memberDetails.first(where: { $0.memberId == "user3" }))
        #expect(영희Detail.totalPaid == 0)
        #expect(Int(영희Detail.totalOwe) == 60_000)
        #expect(Int(영희Detail.netBalance) == -60_000)
        #expect(영희Detail.paidExpenses.isEmpty)
        #expect(영희Detail.sharedExpenses.count == 2)
    }

    @Test("결제자가 여러 번 바뀌는 복잡한 시나리오")
    func complexPayerChanges() throws {
        // given
        let expenses = [
            makeExpense(id: "1", title: "호텔", amount: 120_000, category: .accommodation, payerId: "user1", participants: members),
            makeExpense(id: "2", title: "아침식사", amount: 30_000, category: .foodAndDrink, payerId: "user2", participants: members),
            makeExpense(id: "3", title: "점심식사", amount: 45_000, category: .foodAndDrink, payerId: "user3", participants: members),
            makeExpense(id: "4", title: "저녁식사", amount: 60_000, category: .foodAndDrink, payerId: "user1", participants: members),
            makeExpense(id: "5", title: "교통비", amount: 45_000, category: .transportation, payerId: "user2", participants: members)
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            currentUserId: "user1"
        )

        // then
        let 총지출 = 120_000 + 30_000 + 45_000 + 60_000 + 45_000
        let 개인당지불해야할돈 = 총지출 / 3

        #expect(result.totalExpenseAmount == Double(총지출))
        #expect(Int(result.myShareAmount) == 개인당지불해야할돈)
        #expect(Int(result.myNetBalance) == 80_000)

        #expect(result.paymentsToReceive.count == 2)

        let 철수에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "김철수" })?.amount)
        #expect(Int(철수에게받을돈) == 25_000)

        let 영희에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "이영희" })?.amount)
        #expect(Int(영희에게받을돈) == 55_000)

        #expect(result.paymentsToMake.isEmpty)
    }

    @Test("2명만 참여하는 지출이 섞인 경우")
    func mixedParticipantCounts() throws {
        // given
        let twoMembers1 = [
            TravelMember(id: "user1", name: "홍석현", role: .owner),
            TravelMember(id: "user2", name: "김철수", role: .member)
        ]
        let twoMembers2 = [
            TravelMember(id: "user2", name: "김철수", role: .member),
            TravelMember(id: "user3", name: "이영희", role: .member)
        ]
        let expenses = [
            makeExpense(id: "1", title: "호텔 (3명)", amount: 90_000, category: .accommodation, payerId: "user1", participants: members),
            makeExpense(id: "2", title: "나와 철수 식사 (2명)", amount: 40_000, category: .foodAndDrink, payerId: "user2", participants: twoMembers1),
            makeExpense(id: "3", title: "철수와 영희 술 (2명)", amount: 50_000, category: .foodAndDrink, payerId: "user3", participants: twoMembers2)
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            currentUserId: "user1"
        )

        // then
        #expect(result.totalExpenseAmount == 180_000)
        #expect(Int(result.myShareAmount) == 50_000)
        #expect(Int(result.myNetBalance) == 40_000)

        #expect(result.paymentsToReceive.count == 2)

        let 철수에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "김철수" })?.amount)
        #expect(Int(철수에게받을돈) == 35_000)

        let 영희에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "이영희" })?.amount)
        #expect(Int(영희에게받을돈) == 5_000)

        #expect(result.paymentsToMake.isEmpty)
    }

    @Test("내가 다른 사람들보다 적게 낸 경우")
    func iPaidLessThanOthers() throws {
        // given
        let expenses = [
            makeExpense(id: "1", title: "호텔", amount: 120_000, category: .accommodation, payerId: "user2", participants: members),
            makeExpense(id: "2", title: "식사", amount: 60_000, category: .foodAndDrink, payerId: "user3", participants: members),
            makeExpense(id: "3", title: "커피 (내가 결제)", amount: 12_000, category: .foodAndDrink, payerId: "user1", participants: members)
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            currentUserId: "user1"
        )

        // then
        let 총지출 = 120_000 + 60_000 + 12_000
        let 개인당지불해야할돈 = 총지출 / 3

        #expect(result.totalExpenseAmount == Double(총지출))
        #expect(Int(result.myShareAmount) == 개인당지불해야할돈)
        #expect(Int(result.myNetBalance) == -52_000)

        #expect(result.paymentsToMake.count == 1)

        let 철수에게줄돈 = try #require(result.paymentsToMake.first(where: { $0.memberName == "김철수" })?.amount)
        #expect(Int(철수에게줄돈) == 52_000)

        #expect(result.paymentsToReceive.isEmpty)
    }
}
