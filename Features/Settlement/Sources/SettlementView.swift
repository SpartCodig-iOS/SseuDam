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
import ExpenseListFeature
import SettlementResultFeature

@ViewAction(for: SettlementFeature.self)
public struct SettlementView: View {
    @Bindable public var store: StoreOf<SettlementFeature>

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
                TabButton(title: "지출 내역", isSelected: store.selectedTab == 0) {
                    send(.tabSelected(0))
                }
                TabButton(title: "정산 하기", isSelected: store.selectedTab == 1) {
                    send(.tabSelected(1))
                }
            }
            .padding(.horizontal, 16)

            // 컨텐츠 영역
            if store.selectedTab == 0 {
                ExpenseListView(store: store.scope(state: \.expenseList, action: \.scope.expenseList))
            } else {
                SettlementResultView(store: store.scope(state: \.settlementResult, action: \.scope.settlementResult))
            }
        }
        .background(Color.primary50)
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
