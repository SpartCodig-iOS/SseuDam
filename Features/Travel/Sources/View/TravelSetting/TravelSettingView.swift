//
//  TravelSettingView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/30/25.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

public struct TravelSettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: StoreOf<TravelSettingFeature>

    public init(store: StoreOf<TravelSettingFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if store.isLoading {
                TravelSettingSkeletonView()
            } else {
                content
            }
        }
        .background(Color.primary50)
        .navigationBarBackButtonHidden(true)
        // 여행 나가기 / 삭제 성공 시 dismiss
        .onChange(of: store.shouldDismiss) { _, newValue in
            if newValue {
                dismiss()
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .alert(
            store.errorMessage ?? "",
            isPresented: Binding(
                get: { store.errorMessage != nil },
                set: { _ in store.send(.clearError) }
            )
        ) {
            Button("확인", role: .cancel) { }
        }
        .dsAlert(
            store.scope(state: \.alert, action: \.alert),
            dismissAction: .dismiss
        )
        .toastOverlay()
    }
}

private extension TravelSettingView {
    var content: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Button {
                    dismiss()
                } label: {
                    Image(assetName: "chevronLeft")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .foregroundColor(Color.appBlack)
                }

                Text("여행 설정")
                    .font(.app(.title1, weight: .semibold))
                    .foregroundStyle(Color.appBlack)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)

            ScrollView {
                VStack(spacing: 16) {
                    // 기본 설정
                    IfLetStore(
                        store.scope(state: \.basicInfo, action: \.basicInfo)
                    ) { basicStore in
                        BasicSettingView(store: basicStore)
                    }

                    // 멤버
                    IfLetStore(
                        store.scope(state: \.memberSetting, action: \.memberSetting)
                    ) { memberStore in
                        MemberSettingView(store: memberStore)
                    }

                    // 여행 관리
                    IfLetStore(
                        store.scope(state: \.manage, action: \.manage)
                    ) { manageStore in
                        TravelManageView(store: manageStore)
                    }
                }
                .padding(16)
            }
            .scrollIndicators(.hidden)
        }
        .background(.primary50)
    }
}
