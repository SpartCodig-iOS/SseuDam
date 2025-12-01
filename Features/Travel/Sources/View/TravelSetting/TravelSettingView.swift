//
//  TravelSettingView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/30/25.
//

import SwiftUI
import ComposableArchitecture

public struct TravelSettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: StoreOf<TravelSettingFeature>

    public init(store: StoreOf<TravelSettingFeature>) {
        self.store = store
    }

    public var body: some View {
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
                    //기본 설정
                    BasicSettingView(
                        store: store.scope(
                            state: \.basicInfo,
                            action: \.basicInfo
                        )
                    )

                    //멤버
                    MemberSettingView(
                        store: store.scope(
                            state: \.memberSetting,
                            action: \.memberSetting
                        )
                    )

                    //여행 관리
                    TravelManageView(
                        store: store.scope(
                            state: \.manage,
                            action: \.manage
                        )
                    )
                }
                .padding(16)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.primary50)
        .navigationBarBackButtonHidden(true)
        // 여행 나가기 / 삭제 성공 시 dismiss
        .onChange(of: store.shouldDismiss) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}

//#Preview {
//    TravelSettingView(
//        store: Store(
//            initialState: TravelSettingFeature.State(travel: travel),
//            reducer: {
//                TravelSettingFeature()
//            }
//        )
//    )
//}
