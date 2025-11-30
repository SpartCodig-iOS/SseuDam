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

public struct SettlementView: View {
    @Bindable var store: StoreOf<SettlementFeature>

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

            // 컨텐츠 영역
            Group {
                if selectedTab == 0 {
                    // 헤더
                    SettlementHeaderView(
                        totalAmount: store.totalAmount,
                        startDate: store.startDate,
                        endDate: store.endDate,
                        myExpenseAmount: store.myExpenseAmount,
                        selectedDate: $store.selectedDate
                    )
                    
                    // 지출 내역 리스트
                    ScrollView {
                        Group {
                            if !store.currentExpense.isEmpty {
                                LazyVStack(spacing: 16) {
                                    ForEach(store.currentExpense) { expense in
                                        ExpenseCardView(expense: expense)
                                    }
                                }
                                .padding(.vertical, 10)
                            } else {
                                VStack {
                                    Spacer()
                                    Text("지출이 없습니다.")
                                        .foregroundStyle(.gray)
                                    Spacer()
                                }
                                .frame(height: 300)
                            }
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
                    .frame(height: 300)
                    .frame(maxHeight: .infinity)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(store.travelTitle)
        .toolbarTitleDisplayMode(.inline)
        .onAppear {
            store.send(.onAppear)
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
