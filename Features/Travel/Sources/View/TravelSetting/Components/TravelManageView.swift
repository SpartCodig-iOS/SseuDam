//
//  TravelManageView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/30/25.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

// MARK: - 여행 관리 섹션
struct TravelManageView: View {
    @Bindable var store: StoreOf<TravelManageFeature>
    @State private var isEditing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("여행 관리")
                    .font(.app(.title3, weight: .medium))
                    .foregroundStyle(Color.appBlack)

                Spacer()
            }

            VStack(spacing: 0) {
                Button {
                    store.send(.leaveTapped)
                } label: {
                    HStack {
                        Image(assetName: "logout")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 20)

                        Text("여행 나가기")
                            .font(.app(.title3))

                        Spacer()
                    }
                    .foregroundStyle(Color.appBlack)
                }
                .disabled(store.isSubmitting)

                if store.isOwner {
                    Divider()
                        .foregroundStyle(Color.gray1)
                        .padding(.vertical, 12)

                    Button {
                        store.send(.deleteTapped)
                    } label: {
                        HStack {
                            Image(assetName: "trash")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)

                            Text("여행 삭제")
                                .font(.app(.title3))

                            Spacer()
                        }
                        .foregroundStyle(.red)
                    }
                    .disabled(store.isSubmitting)
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.appWhite)))
        }
    }
}
