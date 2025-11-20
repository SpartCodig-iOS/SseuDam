//
//  TravelCardView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/20/25.
//

import SwiftUI
import DesignSystem

struct TravelCardView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary100)

            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appWhite)
                .offset(x: 5)

            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("D-00")
                        .font(.app(.caption1, weight: .medium))
                        .foregroundColor(Color.primary500)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.primary100)
                        )

                    Text("Label")
                        .font(.app(.title3, weight: .semibold))
                        .foregroundColor(Color.appBlack)

                    HStack(spacing: 0) {
                        Image(systemName: "calendar")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 14)
                            .foregroundStyle(Color.appBlack)
                            .padding(.trailing, 4)

                        Text("yyyy.mm.dd - mm.dd")
                            .font(.app(.body, weight: .medium))
                            .foregroundStyle(Color.gray8)
                            .padding(.trailing, 5)

                        Divider()
                            .frame(width: 1, height: 16)
                            .foregroundStyle(Color.gray2)
                            .padding(.trailing, 6)

                        Image(systemName: "person.2")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 14)
                            .foregroundStyle(Color.appBlack)
                            .padding(.trailing, 4)

                        Text("-명")
                            .font(.app(.body, weight: .medium))
                            .foregroundStyle(Color.gray8)
                    }
                }
                .padding(.trailing, 20)
                .padding(.vertical, 20)
                .padding(.leading, 20)

                Spacer()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    TravelCardView()
}
