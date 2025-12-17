//
//  MemberView.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import Domain

public struct MemberView: View {
    @Bindable var store: StoreOf<MemberManageFeature>

    public init(store: StoreOf<MemberManageFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Button {
                    store.send(.backButtonTapped)
                } label: {
                    Image(assetName: "chevronLeft")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .foregroundColor(Color.appBlack)
                }

                Text("멤버 관리")
                    .font(.app(.title1, weight: .semibold))
                    .foregroundStyle(Color.appBlack)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)

            ScrollView {
                VStack(spacing: 32) {
                    if let myInfo = store.myInfo {
                        MyCardView(myInfo: myInfo)
                    }

                    VStack(spacing: 8) {
                        ForEach(store.members, id: \.id) { member in
                            MemberCardView(member: member, store: store)
                        }
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.primary50)
        .onAppear {
            store.send(.onAppear)
        }
        .dsAlert(
            store.scope(state: \.alert, action: \.alert),
            dismissAction: .dismiss
        )
    }
}

#Preview {
    MemberView(
        store: Store(
            initialState: MemberManageFeature.State(
                travelId: "123",
                members: [
                    TravelMember(
                        id: "",
                        name: "김민희",
                        role: .owner,
                        email: "123@example.com"
                    )
                ],
                myInfo: TravelMember(
                    id: "",
                    name: "이영희",
                    role: .member
                )
            ),
            reducer: { MemberManageFeature() }
        )
    )
}

