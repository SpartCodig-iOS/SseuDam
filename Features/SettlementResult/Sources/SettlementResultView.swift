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
import Domain

@ViewAction(for: SettlementResultFeature.self)
public struct SettlementResultView: View {
    @Bindable public var store: StoreOf<SettlementResultFeature>
    
    public init(store: StoreOf<SettlementResultFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 헤더 (총 지출, 통계)
            if !store.paymentsToMake.isEmpty || !store.paymentsToReceive.isEmpty {
                // 총 지출 (별도)
                VStack(spacing: 8) {
                    Text("총 지출")
                        .font(.app(.body, weight: .medium))
                        .foregroundStyle(Color.gray7)

                    Text(store.formattedTotalExpenseAmount)
                        .font(.app(.title1, weight: .semibold))
                        .foregroundStyle(Color.black)
                }
                .padding(.vertical, 24)

                VStack(spacing: 0) {
                    // 통계 정보 (내 지출, 인원수, 1인 평균)
                    HStack(spacing: 0) {
                        StatItemView(
                            label: "내 지출",
                            value: store.formattedMyExpenseAmount
                        )

                        StatItemView(
                            label: "인원 수",
                            value: "\(store.totalPersonCount)명"
                        )

                        StatItemView(
                            label: "1인 평균",
                            value: store.formattedAveragePerPerson
                        )
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)

                    // 지급/수령 예정 금액 섹션
                    ScrollView {
                        VStack(spacing: 8) {
                            if !store.paymentsToMake.isEmpty {
                                PaymentSectionView(
                                    title: "지급 예정 금액",
                                    totalAmount: CurrencyFormatter.formatKoreanCurrency(
                                        store.paymentsToMake.reduce(0.0) { $0 + $1.amount }
                                    ),
                                    amountColor: .red,
                                    payments: store.paymentsToMake.map {
                                        PaymentItem(
                                            id: $0.id,
                                            name: $0.memberName,
                                            amount: CurrencyFormatter.formatKoreanCurrency($0.amount)
                                        )
                                    }
                                )
                            }

                            if !store.paymentsToReceive.isEmpty {
                                PaymentSectionView(
                                    title: "수령 예정 금액",
                                    totalAmount: CurrencyFormatter.formatKoreanCurrency(
                                        store.paymentsToReceive.reduce(0.0) { $0 + $1.amount }
                                    ),
                                    amountColor: .primary500,
                                    payments: store.paymentsToReceive.map {
                                        PaymentItem(
                                            id: $0.id,
                                            name: $0.memberName,
                                            amount: CurrencyFormatter.formatKoreanCurrency($0.amount)
                                        )
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    .scrollIndicators(.hidden)

                    // 상세보기 버튼
                    Button {
                        send(.detailButtonTapped)
                    } label: {
                        Text("정산 내역 보기")
                            .font(.app(.body, weight: .medium))
                            .foregroundStyle(Color.gray9)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 16)
                    .safeAreaPadding(34)
                }
                .padding(.horizontal, 20)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 20,
                        topTrailingRadius: 20
                    )
                )
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 20,
                        topTrailingRadius: 20
                    )
                    .stroke(Color.gray1, lineWidth: 1)
                )
            } else {
                EmptyCaseView(image: .settlementEmpty, message: "정산 내역이 없습니다")
            }
        }
        .background(Color.primary50)
        .onAppear {
            send(.onAppear)
        }
        .ignoresSafeArea()
        .alert($store.scope(state: \.alert, action: \.scope.alert))
        .sheet(
            item: $store.scope(
                state: \.settlementDetail,
                action: \.scope.settlementDetail
            )
        ) { store in
            SettlementDetailView(store: store)
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
