//
//  SettlementResultView.swift
//  SseuDam
//
//  Created by 홍석현 on 12/4/25.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

public struct SettlementResultView: View {
    @Bindable var store: StoreOf<SettlementResultFeature>
    
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
                                    PaymentItem(id: $0.id, name: $0.toMemberName, amount: Int($0.amount))
                                }
                            )
                        }
                        
                        if !store.paymentsToReceive.isEmpty {
                            PaymentSectionView(
                                title: "수령 예정 금액",
                                totalAmount: store.paymentsToReceive.reduce(0) { $0 + $1.amount },
                                amountColor: .primary500,
                                payments: store.paymentsToReceive.map {
                                    PaymentItem(id: $0.id, name: $0.fromMemberName, amount: Int($0.amount))
                                }
                            )
                        }
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
        .overlay(content: {
            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        })
        .background(Color.primary50)
        .scrollIndicators(.hidden)
        .onAppear {
            store.send(.view(.onAppear))
        }
        .alert($store.scope(state: \.alert, action: \.scope.alert))
    }
}

#Preview {
    NavigationView {
        SettlementResultView(
            store: Store(
                initialState: SettlementResultFeature.State(travelId: "test")
            ) {
                SettlementResultFeature()
            }
        )
    }
}
