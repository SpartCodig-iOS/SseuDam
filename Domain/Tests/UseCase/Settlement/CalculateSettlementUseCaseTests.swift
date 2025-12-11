//
//  CalculateSettlementUseCaseTests.swift
//  Domain
//
//  Created by 홍석현 on 12/10/25.
//

import Testing
@testable import Domain
import Foundation

@Suite("정산 계산 UseCase 테스트")
struct CalculateSettlementUseCaseTests {

    let useCase = CalculateSettlementUseCase()

    // MARK: - Test Data
    let members = [
        TravelMember(id: "user1", name: "홍석현", role: "owner"),
        TravelMember(id: "user2", name: "김철수", role: "member"),
        TravelMember(id: "user3", name: "이영희", role: "member")
    ]

    // MARK: - Tests

    @Test("지출이 없을 때 모든 값이 0")
    func noExpenses() {
        // given
        let expenses: [Expense] = []

        // when
        let result = useCase.execute(
            expenses: expenses,
            members: members,
            currentUserId: "user1"
        )

        // then
        #expect(result.totalExpenseAmount == 0)
        #expect(result.myShareAmount == 0)
        #expect(result.totalPersonCount == 3)
        #expect(result.averagePerPerson == 0)
        #expect(result.myNetBalance == 0)
        #expect(result.paymentsToMake.isEmpty)
        #expect(result.paymentsToReceive.isEmpty)

        // memberDetails 검증
        #expect(result.memberDetails.count == 3)
        for detail in result.memberDetails {
            #expect(detail.totalPaid == 0)
            #expect(detail.totalOwe == 0)
            #expect(detail.netBalance == 0)
            #expect(detail.paidExpenses.isEmpty)
            #expect(detail.sharedExpenses.isEmpty)
        }
    }

    @Test("총 지출 금액 계산 - 단일 지출")
    func totalExpenseAmount_singleExpense() {
        // given
        let expenses = [
            Expense(
                id: "1",
                title: "호텔",
                amount: 100_000,
                currency: "KRW",
                convertedAmount: 100_000,
                expenseDate: Date(),
                category: .accommodation,
                payerId: "user1",
                payerName: "홍석현",
                participants: members
            )
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            members: members,
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
            Expense(
                id: "1",
                title: "호텔",
                amount: 100_000,
                currency: "KRW",
                convertedAmount: 100_000,
                expenseDate: Date(),
                category: .accommodation,
                payerId: "user1",
                payerName: "홍석현",
                participants: members
            ),
            Expense(
                id: "2",
                title: "식사",
                amount: 30_000,
                currency: "KRW",
                convertedAmount: 30_000,
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user2",
                payerName: "김철수",
                participants: members
            )
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            members: members,
            currentUserId: "user1"
        )

        // then
        #expect(result.totalExpenseAmount == 130_000)
        let 개인당지불해야할돈 = (100_000 + 30_000) / 3
        // 내가 지출할 금액 100_000 / 3 + 30_000 / 3
        #expect(Int(result.myShareAmount) == 개인당지불해야할돈)
        
        #expect(result.paymentsToReceive.count == 2)
        #expect(result.paymentsToReceive.contains(where: { $0.memberId == "user2" }))
        #expect(result.paymentsToReceive.contains(where: { $0.memberId == "user3" }))
        let 철수에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "김철수" })?.amount)
        #expect(Int(철수에게받을돈) == abs(개인당지불해야할돈 - 30_000)) // 받아야할 돈 - 철수가 지불한 돈
        let 영희에게받을돈 = try #require(result.paymentsToReceive.first(where: {  $0.memberName == "이영희" })?.amount)
        #expect(Int(영희에게받을돈) == (개인당지불해야할돈))
        #expect(result.paymentsToMake.isEmpty)
    }

    @Test("내 부담 금액 계산 - 모든 지출에 참여")
    func myShareAmount_allExpenses() {
        // given
        let expenses = [
            Expense(
                id: "1",
                title: "호텔",
                amount: 90_000,
                currency: "KRW",
                convertedAmount: 90_000,
                expenseDate: Date(),
                category: .accommodation,
                payerId: "user1",
                payerName: "홍석현",
                participants: members // 3명
            ),
            Expense(
                id: "2",
                title: "식사",
                amount: 30_000,
                currency: "KRW",
                convertedAmount: 30_000,
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user2",
                payerName: "김철수",
                participants: members // 3명
            )
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            members: members,
            currentUserId: "user1"
        )

        // then
        // 내 부담금 = 90,000 / 3 + 30,000 / 3 = 30,000 + 10,000 = 40,000
        #expect(result.myShareAmount == 40_000)
    }

    @Test("내 부담 금액 계산 - 일부 지출만 참여")
    func myShareAmount_partialExpenses() {
        // given
        let expenses = [
            Expense(
                id: "1",
                title: "호텔",
                amount: 90_000,
                currency: "KRW",
                convertedAmount: 90_000,
                expenseDate: Date(),
                category: .accommodation,
                payerId: "user1",
                payerName: "홍석현",
                participants: members // 3명 - 참여함
            ),
            Expense(
                id: "2",
                title: "식사",
                amount: 30_000,
                currency: "KRW",
                convertedAmount: 30_000,
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user2",
                payerName: "김철수",
                participants: [
                    TravelMember(id: "user2", name: "김철수", role: "member"),
                    TravelMember(id: "user3", name: "이영희", role: "member")
                ] // 2명 - 참여 안함
            )
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            members: members,
            currentUserId: "user1"
        )

        // then
        // 내 부담금 = 90,000 / 3 = 30,000 (두 번째 지출은 참여 안함)
        #expect(result.myShareAmount == 30_000)
    }

    @Test("1인 평균 지출 계산")
    func averagePerPerson() {
        // given
        let expenses = [
            Expense(
                id: "1",
                title: "호텔",
                amount: 90_000,
                currency: "KRW",
                convertedAmount: 90_000,
                expenseDate: Date(),
                category: .accommodation,
                payerId: "user1",
                payerName: "홍석현",
                participants: members
            )
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            members: members,
            currentUserId: "user1"
        )

        // then
        // 1인 평균 = 90,000 / 3 = 30,000
        #expect(result.averagePerPerson == 30_000)
    }

    @Test("모든 멤버가 균등하게 결제한 경우 - 정산 없음")
    func allMembersPayEqually() {
        // given - 각자 30,000원씩 결제 (총 90,000원)
        let expenses = [
            Expense(
                id: "1",
                title: "호텔",
                amount: 30_000,
                currency: "KRW",
                convertedAmount: 30_000,
                expenseDate: Date(),
                category: .accommodation,
                payerId: "user1",
                payerName: "홍석현",
                participants: members
            ),
            Expense(
                id: "2",
                title: "식사",
                amount: 30_000,
                currency: "KRW",
                convertedAmount: 30_000,
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user2",
                payerName: "김철수",
                participants: members
            ),
            Expense(
                id: "3",
                title: "교통",
                amount: 30_000,
                currency: "KRW",
                convertedAmount: 30_000,
                expenseDate: Date(),
                category: .transportation,
                payerId: "user3",
                payerName: "이영희",
                participants: members
            )
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            members: members,
            currentUserId: "user1"
        )

        // then
        let 개인당지불해야할돈 = (30_000 * 3) / 3
        #expect(result.totalExpenseAmount == 90_000)
        #expect(Int(result.myShareAmount) == 개인당지불해야할돈)
        #expect(Int(result.myNetBalance) == 0) // 균등하게 냈으므로 순 차액 0
        #expect(result.paymentsToMake.isEmpty)
        #expect(result.paymentsToReceive.isEmpty)
    }

    @Test("내가 아무것도 결제하지 않은 경우 - 빚만 있음")
    func iDidNotPayAnything() throws {
        // given - 나는 참여만 했고 결제는 안함
        let expenses = [
            Expense(
                id: "1",
                title: "호텔",
                amount: 60_000,
                currency: "KRW",
                convertedAmount: 60_000,
                expenseDate: Date(),
                category: .accommodation,
                payerId: "user2",
                payerName: "김철수",
                participants: members
            ),
            Expense(
                id: "2",
                title: "식사",
                amount: 30_000,
                currency: "KRW",
                convertedAmount: 30_000,
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user3",
                payerName: "이영희",
                participants: members
            )
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            members: members,
            currentUserId: "user1"
        )

        // then
        let 개인당지불해야할돈 = (60_000 + 30_000) / 3
        #expect(result.totalExpenseAmount == 90_000)
        #expect(Int(result.myShareAmount) == 개인당지불해야할돈)
        #expect(Int(result.myNetBalance) == -개인당지불해야할돈) // 내가 낸 돈이 없으므로 음수

        // 내가 줘야할 돈
        // 철수: Pay(60,000) - Owe(30,000) = +30,000
        // 영희: Pay(30,000) - Owe(30,000) = 0
        // 따라서 철수에게만 30,000원 지급
        #expect(result.paymentsToMake.count == 1)
        let 철수에게줄돈 = try #require(result.paymentsToMake.first(where: { $0.memberName == "김철수" })?.amount)
        #expect(Int(철수에게줄돈) == 30_000) // 철수의 net balance가 +30,000

        // 받을 돈 없음
        #expect(result.paymentsToReceive.isEmpty)
    }

    @Test("내가 모든 것을 결제한 경우 - 받을 돈만 있음")
    func iPaidEverything() throws {
        // given - 모든 지출을 내가 결제
        let expenses = [
            Expense(
                id: "1",
                title: "호텔",
                amount: 60_000,
                currency: "KRW",
                convertedAmount: 60_000,
                expenseDate: Date(),
                category: .accommodation,
                payerId: "user1",
                payerName: "홍석현",
                participants: members
            ),
            Expense(
                id: "2",
                title: "식사",
                amount: 30_000,
                currency: "KRW",
                convertedAmount: 30_000,
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                payerName: "홍석현",
                participants: members
            )
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            members: members,
            currentUserId: "user1"
        )

        // then
        let 개인당지불해야할돈 = (60_000 + 30_000) / 3
        #expect(result.totalExpenseAmount == 90_000)
        #expect(Int(result.myShareAmount) == 개인당지불해야할돈)
        #expect(Int(result.myNetBalance) == 90_000 - 개인당지불해야할돈) // 내가 모두 냈으므로 양수

        // 받을 돈
        #expect(result.paymentsToReceive.count == 2)
        let 철수에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "김철수" })?.amount)
        #expect(Int(철수에게받을돈) == 개인당지불해야할돈)
        let 영희에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "이영희" })?.amount)
        #expect(Int(영희에게받을돈) == 개인당지불해야할돈)

        // 줄 돈 없음
        #expect(result.paymentsToMake.isEmpty)

        // memberDetails 검증
        #expect(result.memberDetails.count == 3)

        // 나 (홍석현) - 모든 지출을 결제함
        let myDetail = try #require(result.memberDetails.first(where: { $0.memberId == "user1" }))
        #expect(Int(myDetail.totalPaid) == 90_000)
        #expect(Int(myDetail.totalOwe) == 개인당지불해야할돈)
        #expect(Int(myDetail.netBalance) == 90_000 - 개인당지불해야할돈)
        #expect(myDetail.paidExpenses.count == 2) // 호텔, 식사
        #expect(myDetail.sharedExpenses.count == 2) // 모든 지출에 참여

        // 철수 - 아무것도 결제 안함
        let 철수Detail = try #require(result.memberDetails.first(where: { $0.memberId == "user2" }))
        #expect(철수Detail.totalPaid == 0)
        #expect(Int(철수Detail.totalOwe) == 개인당지불해야할돈)
        #expect(Int(철수Detail.netBalance) == -개인당지불해야할돈)
        #expect(철수Detail.paidExpenses.isEmpty)
        #expect(철수Detail.sharedExpenses.count == 2)

        // 영희 - 아무것도 결제 안함
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
        let expenses = [
            Expense(
                id: "1",
                title: "호텔 (3명 모두 참여)",
                amount: 90_000,
                currency: "KRW",
                convertedAmount: 90_000,
                expenseDate: Date(),
                category: .accommodation,
                payerId: "user1",
                payerName: "홍석현",
                participants: members // 3명 참여
            ),
            Expense(
                id: "2",
                title: "술집 (나는 불참)",
                amount: 60_000,
                currency: "KRW",
                convertedAmount: 60_000,
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user2",
                payerName: "김철수",
                participants: [ // 나(user1) 제외
                    TravelMember(id: "user2", name: "김철수", role: "member"),
                    TravelMember(id: "user3", name: "이영희", role: "member")
                ]
            )
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            members: members,
            currentUserId: "user1"
        )

        // then
        #expect(result.totalExpenseAmount == 150_000)
        // 내 부담금 = 90,000 / 3 = 30,000 (술집은 불참이므로 제외)
        #expect(Int(result.myShareAmount) == 30_000)
        // 내 순 차액 = 90,000(결제) - 30,000(부담) = +60,000
        #expect(Int(result.myNetBalance) == 60_000)

        // 받을 돈
        // 철수: Pay(60,000) - Owe(90,000/3 + 60,000/2) = 60,000 - 60,000 = 0 (정산 대상 아님)
        // 영희: Pay(0) - Owe(90,000/3 + 60,000/2) = 0 - 60,000 = -60,000
        #expect(result.paymentsToReceive.count == 1)
        let 영희에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "이영희" })?.amount)
        #expect(Int(영희에게받을돈) == 60_000)

        #expect(result.paymentsToMake.isEmpty)

        // memberDetails 검증
        #expect(result.memberDetails.count == 3)

        // 나 (홍석현) - 호텔만 결제, 호텔만 참여
        let myDetail = try #require(result.memberDetails.first(where: { $0.memberId == "user1" }))
        #expect(Int(myDetail.totalPaid) == 90_000)
        #expect(Int(myDetail.totalOwe) == 30_000) // 90,000 / 3
        #expect(Int(myDetail.netBalance) == 60_000)
        #expect(myDetail.paidExpenses.count == 1) // 호텔만
        #expect(myDetail.sharedExpenses.count == 1) // 호텔만 참여

        // 철수 - 술집 결제, 호텔+술집 참여
        let 철수Detail = try #require(result.memberDetails.first(where: { $0.memberId == "user2" }))
        #expect(Int(철수Detail.totalPaid) == 60_000)
        #expect(Int(철수Detail.totalOwe) == 60_000) // 30,000 + 30,000
        #expect(Int(철수Detail.netBalance) == 0)
        #expect(철수Detail.paidExpenses.count == 1) // 술집만
        #expect(철수Detail.sharedExpenses.count == 2) // 호텔+술집

        // 영희 - 아무것도 결제 안함, 호텔+술집 참여
        let 영희Detail = try #require(result.memberDetails.first(where: { $0.memberId == "user3" }))
        #expect(영희Detail.totalPaid == 0)
        #expect(Int(영희Detail.totalOwe) == 60_000) // 30,000 + 30,000
        #expect(Int(영희Detail.netBalance) == -60_000)
        #expect(영희Detail.paidExpenses.isEmpty)
        #expect(영희Detail.sharedExpenses.count == 2) // 호텔+술집
    }

    @Test("결제자가 여러 번 바뀌는 복잡한 시나리오")
    func complexPayerChanges() throws {
        // given - 5개의 지출, 결제자가 계속 변경됨
        let expenses = [
            Expense(
                id: "1",
                title: "호텔",
                amount: 120_000,
                currency: "KRW",
                convertedAmount: 120_000,
                expenseDate: Date(),
                category: .accommodation,
                payerId: "user1",
                payerName: "홍석현",
                participants: members
            ),
            Expense(
                id: "2",
                title: "아침식사",
                amount: 30_000,
                currency: "KRW",
                convertedAmount: 30_000,
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user2",
                payerName: "김철수",
                participants: members
            ),
            Expense(
                id: "3",
                title: "점심식사",
                amount: 45_000,
                currency: "KRW",
                convertedAmount: 45_000,
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user3",
                payerName: "이영희",
                participants: members
            ),
            Expense(
                id: "4",
                title: "저녁식사",
                amount: 60_000,
                currency: "KRW",
                convertedAmount: 60_000,
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                payerName: "홍석현",
                participants: members
            ),
            Expense(
                id: "5",
                title: "교통비",
                amount: 45_000,
                currency: "KRW",
                convertedAmount: 45_000,
                expenseDate: Date(),
                category: .transportation,
                payerId: "user2",
                payerName: "김철수",
                participants: members
            )
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            members: members,
            currentUserId: "user1"
        )

        // then
        let 총지출 = 120_000 + 30_000 + 45_000 + 60_000 + 45_000
        let 개인당지불해야할돈 = 총지출 / 3

        #expect(result.totalExpenseAmount == Double(총지출))
        #expect(Int(result.myShareAmount) == 개인당지불해야할돈)

        // 내가 결제한 금액: 120,000 + 60,000 = 180,000
        // 내 부담금: 300,000 / 3 = 100,000
        // 순 차액: +80,000
        #expect(Int(result.myNetBalance) == 80_000)

        // 받을 돈
        #expect(result.paymentsToReceive.count == 2)

        // 철수: Pay(30,000 + 45,000 = 75,000) - Owe(100,000) = -25,000
        let 철수에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "김철수" })?.amount)
        #expect(Int(철수에게받을돈) == 25_000)

        // 영희: Pay(45,000) - Owe(100,000) = -55,000
        let 영희에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "이영희" })?.amount)
        #expect(Int(영희에게받을돈) == 55_000)

        #expect(result.paymentsToMake.isEmpty)
    }

    @Test("2명만 참여하는 지출이 섞인 경우")
    func mixedParticipantCounts() throws {
        // given
        let expenses = [
            Expense(
                id: "1",
                title: "호텔 (3명)",
                amount: 90_000,
                currency: "KRW",
                convertedAmount: 90_000,
                expenseDate: Date(),
                category: .accommodation,
                payerId: "user1",
                payerName: "홍석현",
                participants: members // 3명
            ),
            Expense(
                id: "2",
                title: "나와 철수 식사 (2명)",
                amount: 40_000,
                currency: "KRW",
                convertedAmount: 40_000,
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user2",
                payerName: "김철수",
                participants: [ // 2명만
                    TravelMember(id: "user1", name: "홍석현", role: "owner"),
                    TravelMember(id: "user2", name: "김철수", role: "member")
                ]
            ),
            Expense(
                id: "3",
                title: "철수와 영희 술 (2명)",
                amount: 50_000,
                currency: "KRW",
                convertedAmount: 50_000,
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user3",
                payerName: "이영희",
                participants: [ // 나 제외
                    TravelMember(id: "user2", name: "김철수", role: "member"),
                    TravelMember(id: "user3", name: "이영희", role: "member")
                ]
            )
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            members: members,
            currentUserId: "user1"
        )

        // then
        #expect(result.totalExpenseAmount == 180_000)
        // 내 부담금 = 90,000 / 3 + 40,000 / 2 = 30,000 + 20,000 = 50,000
        #expect(Int(result.myShareAmount) == 50_000)
        // 내 순 차액 = 90,000(결제) - 50,000(부담) = +40,000
        #expect(Int(result.myNetBalance) == 40_000)

        // 받을 돈
        #expect(result.paymentsToReceive.count == 2)

        // 철수: Pay(40,000) - Owe(90,000/3 + 40,000/2 + 50,000/2) = 40,000 - 75,000 = -35,000
        let 철수에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "김철수" })?.amount)
        #expect(Int(철수에게받을돈) == 35_000)

        // 영희: Pay(50,000) - Owe(90,000/3 + 50,000/2) = 50,000 - 55,000 = -5,000
        let 영희에게받을돈 = try #require(result.paymentsToReceive.first(where: { $0.memberName == "이영희" })?.amount)
        #expect(Int(영희에게받을돈) == 5_000)

        #expect(result.paymentsToMake.isEmpty)
    }

    @Test("내가 다른 사람들보다 적게 낸 경우")
    func iPaidLessThanOthers() throws {
        // given - 나는 작은 금액만 결제
        let expenses = [
            Expense(
                id: "1",
                title: "호텔",
                amount: 120_000,
                currency: "KRW",
                convertedAmount: 120_000,
                expenseDate: Date(),
                category: .accommodation,
                payerId: "user2",
                payerName: "김철수",
                participants: members
            ),
            Expense(
                id: "2",
                title: "식사",
                amount: 60_000,
                currency: "KRW",
                convertedAmount: 60_000,
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user3",
                payerName: "이영희",
                participants: members
            ),
            Expense(
                id: "3",
                title: "커피 (내가 결제)",
                amount: 12_000,
                currency: "KRW",
                convertedAmount: 12_000,
                expenseDate: Date(),
                category: .foodAndDrink,
                payerId: "user1",
                payerName: "홍석현",
                participants: members
            )
        ]

        // when
        let result = useCase.execute(
            expenses: expenses,
            members: members,
            currentUserId: "user1"
        )

        // then
        let 총지출 = 120_000 + 60_000 + 12_000
        let 개인당지불해야할돈 = 총지출 / 3

        #expect(result.totalExpenseAmount == Double(총지출))
        #expect(Int(result.myShareAmount) == 개인당지불해야할돈)
        // 순 차액 = 12,000 - 64,000 = -52,000
        #expect(Int(result.myNetBalance) == -52_000)

        // 줄 돈
        // 철수: Pay(120,000) - Owe(64,000) = +56,000 (받을 돈)
        // 영희: Pay(60,000) - Owe(64,000) = -4,000 (빚)
        // 따라서 철수에게만 52,000원 지급
        #expect(result.paymentsToMake.count == 1)

        let 철수에게줄돈 = try #require(result.paymentsToMake.first(where: { $0.memberName == "김철수" })?.amount)
        #expect(Int(철수에게줄돈) == 52_000)

        #expect(result.paymentsToReceive.isEmpty)
    }
}
