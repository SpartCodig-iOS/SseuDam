//
//  InfoRow.swift
//  TravelFeature
//
//  Created by 김민희 on 11/30/25.
//

import SwiftUI
import DesignSystem

struct InfoRow: View {
    let title: String
    let value: String
    let imageName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.app(.body, weight: .medium))
                .foregroundColor(.gray7)

            HStack(spacing: 8) {
                if let imageName {
                    Image(assetName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 18)
                        .foregroundStyle(Color.gray8)
                }

                Text(value)
                    .font(.app(.title3, weight: .medium))
                    .foregroundStyle(Color.appBlack)
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    InfoRow(title: "여행 이름", value: "부산 여행", imageName: nil)
}
