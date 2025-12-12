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
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(members, id: \.id) { member in
                MemberRow(
                    name: member.name,
                    isMe: member.id == myId,
                    isOwner: ownerId == member.id
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
