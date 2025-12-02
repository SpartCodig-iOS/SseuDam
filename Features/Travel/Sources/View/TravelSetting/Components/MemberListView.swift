//
//  MemberListView.swift
//  TravelFeature
//
//  Created by 김민희 on 12/2/25.
//

import Foundation
import SwiftUI
import Domain

struct MemberListView: View {
    let members: [TravelMember]
    let myId: String
    let ownerId: String
    let isEditing: Bool
    let onDelegateOwner: (String) -> Void
    let onDelete: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(members, id: \.id) { member in
                MemberRow(
                    name: member.name,
                    isMe: member.id == myId,
                    isOwner: ownerId == member.id,
                    isEditing: isEditing,
                    onDelegateOwner: { onDelegateOwner(member.id) },
                    onDelete: { onDelete(member.id) }
                )
                
                if member.id != members.last?.id {
                    Divider()
                        .foregroundStyle(Color.gray1)
                        .padding(.vertical, 12)
                }
            }
        }
    }
}
