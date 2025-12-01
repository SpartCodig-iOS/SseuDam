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
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .scrollIndicators(.hidden)
                    } else {
                        Spacer()
                        Text("지출이 없습니다.")
                            .foregroundStyle(.gray)
                        Spacer()
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
        .overlay(alignment: .bottomTrailing) {
            if selectedTab == 0 {
                FloatingActionButton {
                    send(.addExpenseButtonTapped)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle(store.travelTitle)
        .toolbarTitleDisplayMode(.inline)
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
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(isSelected ? .black : .gray)
                
                // 선택 표시 줄
                Rectangle()
                    .fill(isSelected ? Color.black : Color.clear)
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
