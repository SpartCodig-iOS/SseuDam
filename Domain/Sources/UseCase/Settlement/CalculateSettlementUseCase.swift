//
//  CalculateSettlementUseCase.swift
//  Domain
//
//  Created by 홍석현 on 12/10/25.
//

import Foundation
import ComposableArchitecture

public protocol CalculateSettlementUseCaseProtocol {
    func execute(
        expenses: [Expense],
        currentUserId: String?
    ) -> SettlementCalculation
}

public struct CalculateSettlementUseCase: CalculateSettlementUseCaseProtocol {

    public init() {}

    public func execute(
        expenses: [Expense],
        currentUserId: String?
    ) -> SettlementCalculation {

        // expenses에서 모든 멤버 추출 (payer + participants)
        let members = extractMembers(from: expenses)
        
        // 1. 총 지출 금액
        let totalExpenseAmount = expenses.reduce(0) { $0 + $1.convertedAmount }
        
        // 2. 내가 부담해야 할 금액 (내가 참여한 지출들의 분담금 합계)
        let myShareAmount: Double
        if let userId = currentUserId {
            myShareAmount = expenses
                .filter { expense in
                    expense.participants.contains(where: { $0.id == userId })
                }
                .reduce(0) { sum, expense in
                    let participantCount = Double(expense.participants.count)
                    guard participantCount > 0 else { return sum }
                    return sum + (expense.convertedAmount / participantCount)
                }
        } else {
            myShareAmount = 0
        }
        
        // 3. 인원수
        let totalPersonCount = members.count
        
        // 4. 1인 평균 지출
        let averagePerPerson = totalPersonCount > 0 ? totalExpenseAmount / Double(totalPersonCount) : 0
        
        // 5. 각 멤버의 순 차액 계산 (Net Balance = Pay - Owe)
        var memberBalances: [String: Double] = [:]
        
        // 모든 멤버 초기화
        for member in members {
            memberBalances[member.id] = 0.0
        }
        
        // 각 지출에 대해 계산
        for expense in expenses {
            let participantCount = Double(expense.participants.count)
            guard participantCount > 0 else { continue }
            
            let amountPerPerson = expense.convertedAmount / participantCount
            
            // 결제자는 전체 금액을 지불한 것으로 (+)
            memberBalances[expense.payer.id, default: 0] += expense.convertedAmount
            
            // 참여자들은 각자 분담금을 빚진 것으로 (-)
            for participant in expense.participants {
                memberBalances[participant.id, default: 0] -= amountPerPerson
            }
        }
        
        // 6. 내 순 차액
        let myNetBalance = currentUserId.flatMap { memberBalances[$0] } ?? 0
        
        // 7. 지급 예정 금액 계산
        let paymentsToMake = calculatePaymentsToMake(
            myBalance: myNetBalance,
            memberBalances: memberBalances,
            members: members,
            currentUserId: currentUserId
        )
        
        // 8. 수령 예정 금액 계산
        let paymentsToReceive = calculatePaymentsToReceive(
            myBalance: myNetBalance,
            memberBalances: memberBalances,
            members: members,
            currentUserId: currentUserId
        )
        
        // 9. 멤버별 정산 상세 계산
        let memberDetails = calculateMemberDetails(
            expenses: expenses,
            members: members,
            memberBalances: memberBalances
        )
        
        return SettlementCalculation(
            totalExpenseAmount: totalExpenseAmount,
            myShareAmount: myShareAmount,
            totalPersonCount: totalPersonCount,
            averagePerPerson: averagePerPerson,
            myNetBalance: myNetBalance,
            paymentsToMake: paymentsToMake,
            paymentsToReceive: paymentsToReceive,
            memberDetails: memberDetails
        )
    }
    
    // MARK: - Private Helper Methods

    // expenses에서 모든 멤버 추출 (중복 제거)
    private func extractMembers(from expenses: [Expense]) -> [TravelMember] {
        var memberDict: [String: TravelMember] = [:]

        for expense in expenses {
            // payer 추가
            memberDict[expense.payer.id] = expense.payer

            // participants 추가
            for participant in expense.participants {
                memberDict[participant.id] = participant
            }
        }

        return Array(memberDict.values)
    }

    // 지급 예정 금액 (내가 빚진 사람들에게 갚아야 할 돈)
    private func calculatePaymentsToMake(
        myBalance: Double,
        memberBalances: [String: Double],
        members: [TravelMember],
        currentUserId: String?
    ) -> [PaymentInfo] {
        guard currentUserId != nil else { return [] }
        guard myBalance < 0 else { return [] } // 내가 받을 돈이 있으면 지급할 것이 없음
        
        // 양수 잔액을 가진 멤버들 (받을 돈이 있는 사람들)
        let creditors = memberBalances
            .filter { $0.value > 0 }
            .sorted { $0.value > $1.value } // 많이 받을 사람부터
        
        var payments: [PaymentInfo] = []
        var remainingDebt = abs(myBalance)
        
        for (memberId, creditAmount) in creditors {
            guard remainingDebt > 0.01 else { break } // 소수점 오차 고려
            
            let paymentAmount = min(remainingDebt, creditAmount)
            
            if let member = members.first(where: { $0.id == memberId }) {
                payments.append(PaymentInfo(
                    id: UUID().uuidString,
                    memberId: memberId,
                    memberName: member.name,
                    amount: paymentAmount
                ))
                remainingDebt -= paymentAmount
            }
        }
        
        return payments
    }
    
    // 수령 예정 금액 (나에게 빚진 사람들로부터 받을 돈)
    private func calculatePaymentsToReceive(
        myBalance: Double,
        memberBalances: [String: Double],
        members: [TravelMember],
        currentUserId: String?
    ) -> [PaymentInfo] {
        guard currentUserId != nil else { return [] }
        guard myBalance > 0 else { return [] } // 내가 빚진 돈이 있으면 받을 것이 없음
        
        // 음수 잔액을 가진 멤버들 (빚진 사람들)
        let debtors = memberBalances
            .filter { $0.value < 0 }
            .sorted { $0.value < $1.value } // 많이 빚진 사람부터
        
        var receipts: [PaymentInfo] = []
        var remainingCredit = myBalance
        
        for (memberId, debtAmount) in debtors {
            guard remainingCredit > 0.01 else { break } // 소수점 오차 고려
            
            let receiptAmount = min(remainingCredit, abs(debtAmount))
            
            if let member = members.first(where: { $0.id == memberId }) {
                receipts.append(PaymentInfo(
                    id: UUID().uuidString,
                    memberId: memberId,
                    memberName: member.name,
                    amount: receiptAmount
                ))
                remainingCredit -= receiptAmount
            }
        }
        
        return receipts
    }
    
    // 멤버별 정산 상세 계산
    // 시간 복잡도: O(E * P + M) - E: 지출 수, P: 평균 참여자 수, M: 멤버 수
    private func calculateMemberDetails(
        expenses: [Expense],
        members: [TravelMember],
        memberBalances: [String: Double]
    ) -> [MemberSettlementDetail] {
        // 1. 멤버별로 결제한 지출과 참여한 지출을 그룹화
        // O(E * P) - 지출을 한 번만 순회
        var memberPaidExpenses: [String: [ExpenseDetail]] = [:]
        var memberSharedExpenses: [String: [ExpenseDetail]] = [:]
        
        for expense in expenses {
            let participantCount = expense.participants.count
            let shareAmount = participantCount > 0 ? expense.convertedAmount / Double(participantCount) : 0
            
            let expenseDetail = ExpenseDetail(
                id: expense.id,
                title: expense.title,
                amount: expense.convertedAmount,
                shareAmount: shareAmount,
                participantCount: participantCount,
                expenseDate: expense.expenseDate
            )
            
            // 결제자에게 추가
            memberPaidExpenses[expense.payer.id, default: []].append(expenseDetail)
            
            // 참여자들에게 추가
            for participant in expense.participants {
                memberSharedExpenses[participant.id, default: []].append(expenseDetail)
            }
        }
        
        // 2. 각 멤버의 정산 상세 생성
        // O(M)
        return members.map { member in
            let paidExpenses = memberPaidExpenses[member.id] ?? []
            let sharedExpenses = memberSharedExpenses[member.id] ?? []
            
            let totalPaid = paidExpenses.reduce(0) { $0 + $1.amount }
            let totalOwe = sharedExpenses.reduce(0) { $0 + $1.shareAmount }
            let netBalance = memberBalances[member.id] ?? 0
            
            return MemberSettlementDetail(
                id: member.id,
                memberId: member.id,
                memberName: member.name,
                netBalance: netBalance,
                totalPaid: totalPaid,
                totalOwe: totalOwe,
                paidExpenses: paidExpenses,
                sharedExpenses: sharedExpenses
            )
        }
    }
}

// MARK: - DependencyKey
public enum CalculateSettlementUseCaseDependencyKey: DependencyKey {
    public static var liveValue: any CalculateSettlementUseCaseProtocol = CalculateSettlementUseCase()
    
    public static var testValue: any CalculateSettlementUseCaseProtocol = CalculateSettlementUseCase()
    
    public static var previewValue: any CalculateSettlementUseCaseProtocol = CalculateSettlementUseCase()
}

public extension DependencyValues {
    var calculateSettlementUseCase: any CalculateSettlementUseCaseProtocol {
        get { self[CalculateSettlementUseCaseDependencyKey.self] }
        set { self[CalculateSettlementUseCaseDependencyKey.self] = newValue }
    }
}
