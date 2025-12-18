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

    // 날짜별로 그룹핑된 결제 항목
    private var groupedPaidExpenses: [ExpensesByDate] {
        detail.paidExpenses.groupedByDate()
    }

    // 날짜별로 그룹핑된 부담 항목
    private var groupedSharedExpenses: [ExpensesByDate] {
        detail.sharedExpenses.groupedByDate()
    }

    var body: some View {
        VStack(spacing: 0) {
            // 헤더 (이름, 총 금액, 펼치기 버튼)
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    onToggle()
                }
            }) {
                HStack(spacing: 12) {
                    // 프로필 아이콘
                    Image(asset: .profile)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)

                    // 이름
                    Text(detail.memberName)
                        .font(.app(.title3, weight: .semibold))
                        .foregroundStyle(Color.black)

                    Spacer()

                    // 총 금액 (결제한 금액 + 부담 금액 합산)
                    Text("₩\(Int(detail.totalPaid + detail.totalOwe).formatted())")
                        .font(.app(.title3, weight: .semibold))
                        .foregroundStyle(Color.black)

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
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.gray2)

                    // 플랫 리스트
                    VStack(spacing: 0) {
                        // 1. 결제한 금액 섹션
                        SectionHeaderRow(title: "결제한 금액", amount: detail.totalPaid)
                            .padding(.vertical, 16)

                        if detail.paidExpenses.isEmpty {
                            Text("결제한 내역이 없습니다")
                                .font(.app(.caption1, weight: .medium))
                                .foregroundStyle(Color.gray7)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        } else {
                            ForEach(groupedPaidExpenses) { dateGroup in
                                VStack(spacing: 0) {
                                    DateHeaderRow(date: dateGroup.date)

                                    VStack(spacing: 12) {
                                        ForEach(dateGroup.expenses) { expense in
                                            ExpenseRow(expense: expense)
                                        }
                                    }
                                    .padding(.top, 8)
                                }
                                .padding(.bottom, 16)
                            }
                        }

                        // 2. 부담 금액 섹션
                        SectionHeaderRow(title: "부담 금액", amount: detail.totalOwe)
                            .padding(.top, 8)
                            .padding(.vertical, 16)

                        if detail.sharedExpenses.isEmpty {
                            Text("부담할 금액이 없습니다")
                                .font(.app(.caption1, weight: .medium))
                                .foregroundStyle(Color.gray7)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        } else {
                            ForEach(groupedSharedExpenses) { dateGroup in
                                VStack(spacing: 0) {
                                    DateHeaderRow(date: dateGroup.date)

                                    VStack(spacing: 12) {
                                        ForEach(dateGroup.expenses) { expense in
                                            ExpenseRow(expense: expense)
                                        }
                                    }
                                    .padding(.top, 8)
                                }
                                .padding(.bottom, 16)
                            }
                        }

                        Divider()
                            .background(Color.gray2)
                            
                        // 3. 받을 돈 / 줄 돈 최종 결과
                        HStack {
                            Text(netBalanceLabel)
                                .font(.app(.body, weight: .medium))
                                .foregroundStyle(Color.black)

                            Spacer()

                            Text(formatAmount(detail.netBalance))
                                .font(.app(.body, weight: .medium))
                                .foregroundStyle(netBalanceColor)
                        }
                        .padding(.vertical, 16)
                    }
                }
                .padding(.horizontal, 20)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95, anchor: .top).combined(with: .opacity),
                    removal: .scale(scale: 0.95, anchor: .top).combined(with: .opacity)
                ))
            }
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray2, lineWidth: 1)
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
            return Color.error
        } else {
            return Color.primary500
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
