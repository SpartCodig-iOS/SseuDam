//
//  InviteCodeModalView.swift
//  TravelFeature
//
//  Created by 김민희 on 12/2/25.
//

import SwiftUI
import DesignSystem

struct InviteCodeModalView: View {
    let code: String
    let onCodeChange: (String) -> Void
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 0) {
                VStack(spacing: 10) {
                    Text("초대 코드를 입력해주세요")
                        .font(.app(.title3, weight: .semibold))
                        .foregroundColor(.appBlack)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)

                    Text("ex) 1A1A1A")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 24)
                }
                .padding(.bottom, 10)
                .padding(.horizontal, 8)

                TextField("", text: Binding(
                    get: { code },
                    set: { onCodeChange($0) }
                ))
                .font(.app(.title3, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(13)
                .background(Color.gray1)
                .cornerRadius(26)
                .padding(.bottom, 29)

                Button(action: onConfirm) {
                    Text("확인")
                        .foregroundColor(Color.appWhite)
                        .font(.app(.title3, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.primary500)
                        .cornerRadius(26)
                }
                .padding(.bottom, 10)

                Button(action: onCancel) {
                    Text("취소")
                        .foregroundColor(Color.appBlack)
                        .font(.app(.title3, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.gray1)
                        .cornerRadius(26)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 34)
                    .fill(Color.primary50)
            )
            .padding(.horizontal, 20)
        }
    }
}
