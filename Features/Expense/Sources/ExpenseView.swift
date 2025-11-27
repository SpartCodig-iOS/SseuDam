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
            .scrollIndicators(.hidden)
            
            PrimaryButton(title: "저장") {
                send(.saveButtonTapped)
            }
        }
        .onAppear {
            send(.onAppear)
        }
        .padding(.horizontal, 16)
        .navigationTitle("지출 추가")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
    }
}

#Preview {
    NavigationStack {
        ExpenseView(
            store: Store(initialState: ExpenseFeature.State("")) {
                ExpenseFeature()
            }
        )
    }
}
