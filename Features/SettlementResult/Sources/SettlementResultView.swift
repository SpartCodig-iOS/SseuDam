//
//  SettlementResultView.swift
//  SseuDam
//
//  Created by 홍석현 on 12/4/25.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import SettlementDetailFeature

@ViewAction(for: SettlementResultFeature.self)
public struct SettlementResultView: View {
    @Bindable public var store: StoreOf<SettlementResultFeature>

    public init(store: StoreOf<SettlementResultFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            // 헤더 (총 지출, 통계)
            SettlementResultHeaderView(
                totalExpenseAmount: store.totalExpenseAmount,
                myExpenseAmount: store.myExpenseAmount,
                totalPersonCount: store.totalPersonCount
            )

            if !store.paymentsToMake.isEmpty || !store.paymentsToReceive.isEmpty {
                // 지급/수령 예정 금액 섹션
                ScrollView {
                    VStack(spacing: 8) {
                        if !store.paymentsToMake.isEmpty {
                            PaymentSectionView(
                                title: "지급 예정 금액",
                                totalAmount: store.paymentsToMake.reduce(0) { $0 + $1.amount },
                                amountColor: .red,
                                payments: store.paymentsToMake.map {
                                    PaymentItem(id: $0.id, name: $0.memberName, amount: Int($0.amount))
                                }
                            )
                        }

                        if !store.paymentsToReceive.isEmpty {
                            PaymentSectionView(
                                title: "수령 예정 금액",
                                totalAmount: store.paymentsToReceive.reduce(0) { $0 + $1.amount },
                                amountColor: .primary500,
                                payments: store.paymentsToReceive.map {
                                    PaymentItem(id: $0.id, name: $0.memberName, amount: Int($0.amount))
                                }
                            )
                        }

                        // 상세보기 버튼
                        Button {
                            send(.detailButtonTapped)
                        } label: {
                            HStack {
                                Text("멤버별 정산 상세보기")
                                    .font(.app(.body, weight: .semibold))
                                    .foregroundStyle(Color.primary500)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.primary500)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                }
            } else {
                VStack {
                    Image(asset: .expenseEmpty)
                        .resizable()
                        .frame(width: 167, height: 167)
                    Text("정산 내역이 없습니다.")
                        .font(.app(.title3, weight: .medium))
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .background(Color.primary50)
        .scrollIndicators(.hidden)
        .onAppear {
           send(.onAppear)
        }
        .alert($store.scope(state: \.alert, action: \.scope.alert))
        .sheet(item: $store.scope(state: \.settlementDetail, action: \.scope.settlementDetail)) { store in
            NavigationView {
                SettlementDetailView(store: store)
            }
        }
    }
}

#Preview {
    NavigationView {
        SettlementResultView(
            store: Store(
                initialState: SettlementResultFeature.State(
                    travelId: "test",
                    travel: .init(value: nil),
                    expenses: .init(value: [])
                )
            ) {
                SettlementResultFeature()
            }
        )
    }
}
