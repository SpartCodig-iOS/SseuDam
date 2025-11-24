//
//  SelectField.swift
//  TravelFeature
//
//  Created by 김민희 on 11/21/25.
//

import SwiftUI
import DesignSystem

struct SelectField: View {
    var title: String
    var essential: Bool
    var placeholder: String
    var value: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 2) {
                if essential {
                    Text("*")
                        .font(.app(.title3, weight: .medium))
                        .foregroundColor(.red)
                }

                Text(title)
                    .font(.app(.title3, weight: .medium))
                    .foregroundStyle(Color.appBlack)
            }

            HStack {
                Text(value ?? placeholder)
                    .font(.app(.body, weight: .medium))
                    .foregroundColor(value == nil ? Color.gray2 : Color.appBlack)

                Spacer()
                
                Image(assetName: "chevronRight")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
                    .foregroundColor(Color.gray5)
            }
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray2, lineWidth: 1)
            )
        }
    }
}

#Preview {
    SelectField(title: "국가", essential: true, placeholder: "여행 국가", value: "한국")
}
