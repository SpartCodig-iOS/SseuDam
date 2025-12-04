//
//  SettlementView.swift
//  SettlementFeature
//
//  Created by 홍석현 on 11/28/25.
//

import SwiftUI
import Domain
import ComposableArchitecture
import DesignSystem

@ViewAction(for: SettlementFeature.self)
public struct SettlementView: View {
    @Bindable public var store: StoreOf<SettlementFeature>
    
    @State private var selectedTab: Int = 0 // 0: 지출 내역, 1: 정산 하기
    
    public init(store: StoreOf<SettlementFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 네비게이션 바
            NavigationBarView(
                title: store.travelTitle,
                onBackTapped: {
                    send(.backButtonTapped)
                }
            ) {
                TrailingButton(icon: .settings) {
                    send(.settingsButtonTapped)
                }
            }
            .padding(.horizontal, 16)
            // 탭 바 (Custom Segmented Control)
            HStack(spacing: 0) {
                TabButton(title: "지출 내역", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "정산 하기", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
            }
            .padding(.horizontal, 16)
            
            // 컨텐츠 영역
            if selectedTab == 0 {
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
            } else {
                // 정산 하기 뷰 (아직 미구현)
                VStack {
                    Spacer()
                    Text("정산 하기 화면 준비 중")
                        .foregroundStyle(.gray)
                    Spacer()
                }
            }
        }
        .overlay(alignment: .top) {
            if store.isLoading {
                DashboardSkeletonView()
            }
        }
        .background(Color.primary50.ignoresSafeArea())
        .overlay(alignment: .bottomTrailing) {
            if !store.isLoading && selectedTab == 0 {
                FloatingActionButton {
                    send(.addExpenseButtonTapped)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            send(.onAppear)
        }
    }
}

// MARK: - Custom Tab Button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.app(.title3, weight: .medium))
                    .foregroundStyle(Color.black)
                
                // 선택 표시 줄
                Rectangle()
                    .fill(isSelected ? Color.primary500 : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationView {
        SettlementView(
            store: Store(
                initialState: SettlementFeature.State("travel_01"),
                reducer: { SettlementFeature() }
            )
        )
    }
}
