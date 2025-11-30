//
//  MemberRow.swift
//  TravelFeature
//
//  Created by 김민희 on 11/30/25.
//

import SwiftUI
import DesignSystem

struct MemberRow: View {
    let name: String
    var isMe: Bool = false
    
    var body: some View {
        HStack {
            Image(assetName: "profile")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .foregroundStyle(Color.primary500)
                .background(
                    Circle()
                        .fill(Color.primary50)
                )

            Text(name)
                .font(.app(.body, weight: .medium))

            Spacer()
            
            if isMe {
                Text("나")
                    .font(.app(.body, weight: .medium))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 6)
                    .foregroundStyle(Color.gray7)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.primary100)
                    )
            }
        }
    }
}

#Preview {
    MemberRow(name: "김민수", isMe: true)
}
