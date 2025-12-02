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
    @State private var isEditing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            SectionHeader(title: "멤버", isOWner: store.travel.role == "owner", isEditing: $isEditing)

            let members = store.members
            //TODO: 내 아이디
            let myId = store.members.first?.id ?? ""
            let ownerId = store.ownerId

            MemberListView(
                members: members,
                myId: myId,
                ownerId: ownerId,
                isEditing: isEditing,
                onDelegateOwner: { memberId in
                    store.send(.delegateOwnerTapped(memberId))
                },
                onDelete: { memberId in
                    store.send(.deleteMemberTapped(memberId))
                }
            )
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.appWhite))
            )
        }
    }
}
