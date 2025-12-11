//
//  MemberSettingView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/30/25.
//

import SwiftUI
import ComposableArchitecture

// MARK: - 멤버 섹션
struct MemberSettingView: View {
    @Bindable var store: StoreOf<MemberSettingFeature>
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            let myId = store.members.first?.id ?? ""
            let ownerId = store.members.first(where: { $0.role == .owner })?.id
            let isOwner = (ownerId == myId)

            SectionHeader(
                title: "멤버",
                isOWner: isOwner,
                isEditing: Binding.constant(false),
                editAction: {
                    store.send(.editButtonTapped)
                }
            )

            MemberListView(
                members: store.members,
                myId: myId,
                ownerId: ownerId ?? ""
            )
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.appWhite))
            )
        }
    }
}
