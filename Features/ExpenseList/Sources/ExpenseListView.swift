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
            if !store.allExpenses.isEmpty {
                // 헤더
                SettlementHeaderView(
                    totalAmount: store.formattedTotalAmount,
                    startDate: store.startDate,
                    endDate: store.endDate,
                    myExpenseAmount: store.formattedTotalAmount, // 임시로 동일
                    expenses: store.allExpenses,
                    selectedDateRange: $store.selectedDateRange,
                    currentPage: $store.currentPage
                )
                
                // 카테고리 필터
                CategoryFilterView(
                    selectedCategory: $store.selectedCategory
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                // 지출 내역 리스트
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(store.currentExpense) { expense in
                            ExpenseCardView(expense: expense)
                                .onTapGesture {
                                    send(.onTapExpense(expense))
                                }
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.95, anchor: .top)
                                        .combined(with: .opacity)
                                        .combined(with: .move(edge: .top)),
                                    removal: .scale(scale: 0.95, anchor: .top)
                                        .combined(with: .opacity)
                                ))
                        }
                    }
                    .padding(.vertical, 10)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: store.currentExpense.count)
                }
                .scrollIndicators(.hidden)
            } else {
                VStack {
                    Image(asset: .expenseEmpty)
                        .resizable()
                        .frame(width: 167, height: 167)
                    Text("아직 지출이 없어요")
                        .font(.app(.title3, weight: .medium))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                initialState: ExpenseListFeature.State(
                    travelId: "travel_01",
                    travel: .init(value: nil),
                    expenses: .init(value: [])
                )
            ) {
                ExpenseListFeature()
            }
        )
    }
}
