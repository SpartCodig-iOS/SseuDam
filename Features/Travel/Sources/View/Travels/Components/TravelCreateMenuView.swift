//
//  TravelCreateMenuView.swift
//  TravelFeature
//
//  Created by 김민희 on 12/2/25.
//

import SwiftUI
import DesignSystem

struct TravelCreateMenuView: View {
    let inviteTapped: () -> Void
    let createTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button(action: inviteTapped) {
                HStack(spacing: 10) {
                    Image(assetName: "fileInput")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                    Text("초대 코드 입력")
                        .font(.app(.title3, weight: .medium))
                        .foregroundStyle(Color.gray7)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
            }

            Button(action: createTapped) {
                HStack(spacing: 10) {
                    Image(assetName: "terms")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                    Text("새 여행 만들기")
                        .font(.app(.title3, weight: .medium))
                        .foregroundStyle(Color.gray7)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 8)
        .background(Color.appWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 0)
    }
}
