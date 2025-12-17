//
//  InvitationCodeView.swift
//  ExpenseListFeature
//
//  Created by 홍석현 on 12/17/25.
//

import SwiftUI
import DesignSystem

struct InvitationCodeView: View {
    @State private var isExpanded: Bool = false
    private let invitationCode: String
    private let deepLinkURL: URL
    
    init(
        invitationCode: String,
        deepLinkURL: URL
    ) {
        self.invitationCode = invitationCode
        self.deepLinkURL = deepLinkURL
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("여행 초대코드")
                    .font(.app(.caption1, weight: .medium))
                    .foregroundStyle(Color.gray5)

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.75)) {
                        isExpanded.toggle()
                    }
                }, label: {
                    HStack(spacing: 2) {
                        Text(isExpanded ? "접기" : "펼치기")
                            .font(.app(.caption2, weight: .regular))

                        Image(systemName: "chevron.down")
                            .resizable()
                            .frame(width: 6, height: 3)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .foregroundStyle(Color.gray4)
                })
            }

            if isExpanded {
                VStack(spacing: 4) {
                    Text("여행 코드를 공유해 여행 멤버를 초대하세요!")
                        .font(.app(.caption2, weight: .regular))
                        .foregroundStyle(Color.gray4)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 10) {
                        Text(invitationCode)
                            .font(.app(.title2, weight: .medium))
                            .foregroundStyle(Color.gray8)

                        Spacer()

                        Button(action: {
                            InviteCodeHelper.copyToClipboard(invitationCode)
                        }, label: {
                            Image(asset: .copy)
                                .resizable()
                                .frame(width: 32, height: 32)
                        })

                        Button(action: {
                            InviteCodeHelper.shareDeepLink(deepLinkURL)
                        }, label: {
                            Image(asset: .upload)
                                .resizable()
                                .frame(width: 32, height: 32)
                        })
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .padding(20)
    }
}

#Preview {
    InvitationCodeView(
        invitationCode: "1A1A1A",
        deepLinkURL: URL(string: "")!
    )
}
