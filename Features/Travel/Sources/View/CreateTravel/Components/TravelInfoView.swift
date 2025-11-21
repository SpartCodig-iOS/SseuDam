//
//  TravelInfoView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/21/25.
//

import SwiftUI
import DesignSystem

struct TravelInfoView: View {
    @Binding var title: String
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("여행 정보")
                .font(.app(.title3, weight: .semibold))
                .foregroundStyle(Color.appBlack)

            VStack(spacing: 16) {
                InputTextField(
                    text: $title,
                    title: "여행 이름",
                    essential: true,
                    placeholder: "ex) 제주도 여행",
                    isEnabled: true
                )

                SelectField(
                    title: "국가", 
                    essential: true,
                    placeholder: "국가를 선택해주세요"
                )
            }

        }
    }
}

#Preview {
    TravelInfoView(title: .constant(""))
}
