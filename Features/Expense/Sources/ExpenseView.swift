//
//  ExpenseView.swift
//  SseuDam
//
//  Created by SseuDam on 2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import DesignSystem
import Domain
import IdentifiedCollections
import ComposableArchitecture

@ViewAction(for: ExpenseFeature.self)
public struct ExpenseView: View {
    @Bindable private(set) public var store: StoreOf<ExpenseFeature>
    
    public init(store: StoreOf<ExpenseFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 네비게이션 바
            NavigationBarView(
                title: store.isEditMode ? "지출 수정" : "지출 추가",
                onBackTapped: {
                    send(.backButtonTapped)
                }
            ) {
                if store.isEditMode {
                    TrailingButton(text: "삭제") {
                        send(.deleteButtonTapped)
                    }
                }
            }

            ScrollView {
                VStack(spacing: 20) {
                    // 1. 지출 제목
                    TextInputField(
                        label: "지출 제목",
                        placeholder: "ex) 점심 식사",
                        text: $store.title
                    )

                    // 2. 지출 금액
                    AmountInputField(
                        amount: $store.amount,
                        baseCurrency: store.baseCurrency,
                        convertedAmountKRW: store.convertedAmountKRW
                    )

                    // 3. 지출일
                    DatePickerField(
                        label: "지출일",
                        date: $store.expenseDate,
                        startDate: store.travelStartDate,
                        endDate: store.travelEndDate
                    )

                    // 4. 카테고리
                    CategorySelector(selectedCategory: $store.selectedCategory)

                    // 5. 결제자 & 참여자
                    ParticipantSelectorView(
                        store: store.scope(
                            state: \.participantSelector,
                            action: \.scope.participantSelector
                        )
                    )
                }
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.immediately)
            .scrollIndicators(.hidden)

            // 저장/수정 버튼
            PrimaryButton(
                title: store.isEditMode ? "수정" : "저장",
                isEnabled: store.canSave
            ) {
                send(.saveButtonTapped)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .navigationBarBackButtonHidden(true)
        .background(Color.white)
        .alert($store.scope(state: \.deleteAlert, action: \.scope.deleteAlert))
        .overlay {
            if store.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .tint(.white)
                            .controlSize(.large)
                    }
            }
        }
    }
}

#Preview {
    let mockTravel = Travel(
        id: "mock_travel_id",
        title: "오사카 여행",
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 7),
        countryCode: "JP",
        baseCurrency: "JPY",
        baseExchangeRate: 9.0,
        destinationCurrency: "JPY",
        status: .active,
        createdAt: Date(),
        ownerName: "홍길동",
        members: [
            TravelMember(id: "user1", name: "홍길동", role: "owner"),
            TravelMember(id: "user2", name: "김철수", role: "member")
        ]
    )

    NavigationStack {
        ExpenseView(
            store: Store(initialState: ExpenseFeature.State(travel: mockTravel)) {
                ExpenseFeature()
            }
        )
    }
}
