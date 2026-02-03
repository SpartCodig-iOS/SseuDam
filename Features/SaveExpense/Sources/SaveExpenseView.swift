//
//  SaveExpenseView.swift
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

@ViewAction(for: SaveExpenseFeature.self)
public struct SaveExpenseView: View {
    @Bindable private(set) public var store: StoreOf<SaveExpenseFeature>
    
    public init(store: StoreOf<SaveExpenseFeature>) {
        self.store = store
    }
    
    public var body: some View {
        content
    }

    private var content: some View {
        VStack(spacing: 0) {
            navigationBar
            form
            saveButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .navigationBarBackButtonHidden(true)
        .background(Color.white)
        .alert($store.scope(state: \.deleteAlert, action: \.scope.deleteAlert))
        .alert($store.scope(state: \.errorAlert, action: \.scope.errorAlert))
        .overlay(loadingOverlay)
    }

    private var navigationBar: some View {
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
    }

    private var form: some View {
        ScrollView {
            VStack(spacing: 20) {
                receiptHeader
                titleInput
                amountInput
                dateInput
                categoryInput
                participantSelector
            }
            .padding(.bottom, 16)
        }
        .scrollDismissesKeyboard(.immediately)
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var receiptHeader: some View {
        if let data = store.receiptImage,
           let uiImage = UIImage(data: data) {
            ReceiptHeaderView(
                image: uiImage,
                onZoom: { send(.receiptZoomTapped) },
            )
            .padding(.top, 8)
        }
    }

    private var titleInput: some View {
        TextInputField(
            label: "지출 제목",
            placeholder: "ex) 점심 식사",
            text: $store.title
        )
    }

    private var amountInput: some View {
        AmountInputField(
            amount: $store.amount,
            baseCurrency: store.baseCurrency,
            convertedAmountKRW: store.convertedAmountKRW
        )
    }

    private var dateInput: some View {
        DatePickerField(
            label: "지출일",
            date: $store.expenseDate,
            startDate: store.travelStartDate,
            endDate: store.travelEndDate
        )
    }

    private var categoryInput: some View {
        CategorySelector(selectedCategory: $store.selectedCategory)
    }

    private var participantSelector: some View {
        ParticipantSelectorView(
            store: store.scope(
                state: \.participantSelector,
                action: \.scope.participantSelector
            )
        )
    }

    private var saveButton: some View {
        PrimaryButton(
            title: store.isEditMode ? "수정" : "저장",
            isEnabled: store.canSave
        ) {
            send(.saveButtonTapped)
        }
    }

    @ViewBuilder
    private var loadingOverlay: some View {
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

#Preview {
    let mockTravel = Travel(
        id: "mock_travel_id",
        title: "오사카 여행",
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 7),
        countryCode: "JP",
        koreanCountryName: "일본",
        baseCurrency: "JPY",
        baseExchangeRate: 9.0,
        destinationCurrency: "JPY",
        status: .active,
        createdAt: Date(),
        ownerName: "홍길동",
        members: [
            TravelMember(id: "user1", name: "홍길동", role: .owner),
            TravelMember(id: "user2", name: "김철수", role: .member)
        ],
        currencies: ["JPY"]
    )

    var state = SaveExpenseFeature.State(travel: mockTravel)

    state.receiptImage = UIImage(systemName: "doc.text.image")?
        .withTintColor(.black, renderingMode: .alwaysOriginal)
        .pngData()

    return NavigationStack {
        SaveExpenseView(
            store: Store(initialState: state) {
                SaveExpenseFeature()
            }
        )
    }
}
