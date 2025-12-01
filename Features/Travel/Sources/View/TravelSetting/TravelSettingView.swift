//
//  TravelSettingView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/30/25.
//

import SwiftUI
import ComposableArchitecture

public struct TravelSettingView: View {
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Button {
                    dismiss()
                } label: {
                    Image(assetName: "chevronLeft")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .foregroundColor(Color.appBlack)
                }

                Text("여행 설정")
                    .font(.app(.title1, weight: .semibold))
                    .foregroundStyle(Color.appBlack)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)

            ScrollView {
                VStack(spacing: 16) {
                    //기본 설정
                    BasicSettingView()

                    //멤버
                    MemberSettingView()

                    //여행 관리
                    TravelManageView()
                }
                .padding(16)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.primary50)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TravelSettingView()
}
