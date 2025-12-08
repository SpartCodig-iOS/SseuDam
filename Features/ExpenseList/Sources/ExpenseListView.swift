//
//  ExpenseListView.swift
//  ExpenseListFeature
//
//  Created by 홍석현 on 12/8/25.
//

import SwiftUI
import Domain
import ComposableArchitecture
import DesignSystem

@ViewAction(for: ExpenseListFeature.self)
public struct ExpenseListView: View {
    @Bindable public var store: StoreOf<ExpenseListFeature>

    public init(store: StoreOf<ExpenseListFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            // 헤더
            SettlementHeaderView(
                totalAmount: store.totalAmount,
                startDate: store.startDate,
                endDate: store.endDate,
                myExpenseAmount: store.myExpenseAmount,
                selectedDate: $store.selectedDate
            )

            // 지출 내역 리스트
            if !store.currentExpense.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(store.currentExpense) { expense in
                            ExpenseCardView(expense: expense)
                                .onTapGesture {
                                    send(.onTapExpense(expense))
                                }
                        }
                    }
                    .padding(.vertical, 10)
                }
                .scrollIndicators(.hidden)
            } else {
                VStack {
                    Image(asset: .expenseEmpty)
                        .resizable()
                        .frame(width: 167, height: 167)
                    Text("지출을 추가해보세요!")
                        .font(.app(.title3, weight: .medium))
                }
                .frame(maxHeight: .infinity)
            }
        }
        .overlay {
            if store.isLoading {
                DashboardSkeletonView()
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if !store.isLoading {
                FloatingActionButton {
                    send(.addExpenseButtonTapped)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            send(.onAppear)
        }
        .alert($store.scope(state: \.alert, action: \.scope.alert))
    }
}

#Preview {
    NavigationView {
        ExpenseListView(
            store: Store(
                initialState: ExpenseListFeature.State(travelId: "travel_01")
            ) {
                ExpenseListFeature()
            }
        )
    }
}
