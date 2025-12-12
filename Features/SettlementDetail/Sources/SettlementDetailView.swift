//
//  SettlementDetailView.swift
//  SettlementDetailFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import Domain

public struct SettlementDetailView: View {
    private let store: StoreOf<SettlementDetailFeature>

    public init(store: StoreOf<SettlementDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 내 정산 상세
                if let myDetail = store.myDetail {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("내 정산 내역")
                            .font(.app(.title3, weight: .semibold))
                            .foregroundStyle(Color.black)

                        MemberDetailCard(
                            detail: myDetail,
                            isExpanded: store.expandedMemberIds.contains(myDetail.memberId),
                            isCurrentUser: true,
                            onToggle: {
                                store.send(.toggleMemberExpansion(myDetail.memberId))
                            }
                        )
                    }
                }

                // 다른 멤버들
                if !store.otherMemberDetails.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("다른 멤버")
                            .font(.app(.title3, weight: .semibold))
                            .foregroundStyle(Color.black)

                        VStack(spacing: 12) {
                            ForEach(store.otherMemberDetails) { detail in
                                MemberDetailCard(
                                    detail: detail,
                                    isExpanded: store.expandedMemberIds.contains(detail.memberId),
                                    isCurrentUser: false,
                                    onToggle: {
                                        store.send(.toggleMemberExpansion(detail.memberId))
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .scrollIndicators(.hidden)
        .background(Color.primary50)
        .presentationDragIndicator(.visible)
        .navigationTitle("정산 내역")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let calendar = Calendar.current
    let today = Date()
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

    return NavigationView {
        SettlementDetailView(
            store: Store(
                initialState: SettlementDetailFeature.State(
                    memberDetails: [
                        MemberSettlementDetail(
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
                        MemberSettlementDetail(
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
                        )
                    ],
                    currentUserId: "user1"
                )
            ) {
                SettlementDetailFeature()
            }
        )
    }
}
