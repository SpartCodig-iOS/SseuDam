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
    let store: StoreOf<SettlementFeature>

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
            
            // 헤더
            SettlementHeaderView(
                currentDate: "2024.12.20",
                totalAmount: 255450,
                startDate: "2024.12.20",
                endDate: "2024.12.25",
                myExpenseAmount: 255450
            )

            // 컨텐츠 영역
            ScrollView {
                if selectedTab == 0 {
                    // 지출 내역 리스트
                    LazyVStack(spacing: 16) {
                        ForEach(Expense.mockList) { expense in
                            ExpenseCardView(expense: expense)
                        }
                    }
                    .padding(.vertical, 10)
                } else {
                    // 정산 하기 뷰 (아직 미구현)
                    VStack {
                        Spacer()
                        Text("정산 하기 화면 준비 중")
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                    .frame(height: 300)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("오사카 여행")
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
                initialState: SettlementFeature.State(),
                reducer: { SettlementFeature() }
            )
        )
    }
}
