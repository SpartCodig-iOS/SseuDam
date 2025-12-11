//
//  MemberDetailCard.swift
//  SettlementDetailFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem
import Domain

struct MemberDetailCard: View {
    let detail: MemberSettlementDetail
    let isExpanded: Bool
    let isCurrentUser: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 헤더 (이름, 순 차액, 펼치기 버튼)
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    onToggle()
                }
            }) {
                HStack(spacing: 12) {
                    // 프로필 아이콘
                    Image(asset: .profile)
                        .resizable()
                        .foregroundStyle(Color.primary500)
                        .frame(width: 40, height: 40)

                    // 이름
                    Text(detail.memberName)
                        .font(.app(.title3, weight: .semibold))
                        .foregroundStyle(Color.black)

                    Spacer()

                    // 순 차액
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(netBalanceLabel)
                            .font(.app(.caption1, weight: .medium))
                            .foregroundStyle(Color.gray7)

                        Text(formatAmount(detail.netBalance))
                            .font(.app(.title3, weight: .semibold))
                            .foregroundStyle(netBalanceColor)
                    }

                    // 펼치기 아이콘
                    Image(systemName: "chevron.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.gray7)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // 상세 내용 (펼쳤을 때만 표시)
            if isExpanded {
                VStack(spacing: 16) {
                    Divider()
                        .background(Color.gray2)

                    // 결제 금액
                    ExpenseBreakdownSection(
                        title: "결제한 금액",
                        totalAmount: detail.totalPaid,
                        expenses: detail.paidExpenses,
                        showEmpty: true
                    )
                    .opacity(isExpanded ? 1 : 0)
                    .scaleEffect(isExpanded ? 1 : 0.95, anchor: .top)

                    // 부담 금액
                    ExpenseBreakdownSection(
                        title: "부담 금액",
                        totalAmount: detail.totalOwe,
                        expenses: detail.sharedExpenses,
                        showEmpty: false
                    )
                    .opacity(isExpanded ? 1 : 0)
                    .scaleEffect(isExpanded ? 1 : 0.95, anchor: .top)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95, anchor: .top).combined(with: .opacity),
                    removal: .scale(scale: 0.95, anchor: .top).combined(with: .opacity)
                ))
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray1, lineWidth: 1)
        )
    }

    private var netBalanceLabel: String {
        if detail.netBalance > 0 {
            return "받을 돈"
        } else if detail.netBalance < 0 {
            return "줄 돈"
        } else {
            return "정산 완료"
        }
    }

    private var netBalanceColor: Color {
        if detail.netBalance > 0 {
            return .primary500
        } else if detail.netBalance < 0 {
            return .red
        } else {
            return .black
        }
    }

    private func formatAmount(_ amount: Double) -> String {
        let absAmount = abs(amount)
        return "₩\(Int(absAmount).formatted())"
    }
}

#Preview {
    let calendar = Calendar.current
    let today = Date()
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

    return VStack(spacing: 16) {
        // 받을 돈이 있는 경우
        MemberDetailCard(
            detail: MemberSettlementDetail(
                id: "1",
                memberId: "user1",
                memberName: "홍석현",
                netBalance: 53227,
                totalPaid: 280000,
                totalOwe: 226773,
                paidExpenses: [
                    ExpenseDetail(id: "1", title: "호텔", amount: 120000, shareAmount: 40000, participantCount: 3, expenseDate: twoDaysAgo),
                    ExpenseDetail(id: "2", title: "저녁식사", amount: 60000, shareAmount: 30000, participantCount: 2, expenseDate: yesterday),
                    ExpenseDetail(id: "3", title: "커피", amount: 100000, shareAmount: 33333, participantCount: 3, expenseDate: today)
                ],
                sharedExpenses: [
                    ExpenseDetail(id: "1", title: "호텔", amount: 120000, shareAmount: 40000, participantCount: 3, expenseDate: twoDaysAgo),
                    ExpenseDetail(id: "2", title: "저녁식사", amount: 60000, shareAmount: 30000, participantCount: 2, expenseDate: yesterday),
                    ExpenseDetail(id: "3", title: "커피", amount: 100000, shareAmount: 33333, participantCount: 3, expenseDate: today)
                ]
            ),
            isExpanded: true,
            isCurrentUser: true,
            onToggle: {}
        )

        // 줄 돈이 있는 경우
        MemberDetailCard(
            detail: MemberSettlementDetail(
                id: "2",
                memberId: "user2",
                memberName: "김철수",
                netBalance: -52000,
                totalPaid: 0,
                totalOwe: 52000,
                paidExpenses: [],
                sharedExpenses: [
                    ExpenseDetail(id: "1", title: "호텔", amount: 120000, shareAmount: 40000, participantCount: 3, expenseDate: twoDaysAgo),
                    ExpenseDetail(id: "3", title: "커피", amount: 100000, shareAmount: 33333, participantCount: 3, expenseDate: today)
                ]
            ),
            isExpanded: false,
            isCurrentUser: false,
            onToggle: {}
        )
    }
    .padding(16)
    .background(Color.primary50)
}
