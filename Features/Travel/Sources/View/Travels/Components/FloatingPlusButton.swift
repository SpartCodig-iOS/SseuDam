//
//  FloatingPlusButton.swift
//  TravelFeature
//
//  Created by 김민희 on 11/24/25.
//

import SwiftUI
import DesignSystem

struct FloatingPlusButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(assetName: "plus")
                .resizable()
                .scaledToFit()
                .frame(height: 14)
                .foregroundStyle(Color.appWhite)
                .padding(19)
                .background(Color.primary500)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
        }
    }
}

#Preview {
    FloatingPlusButton {
        print("Tapped!")
    }
}
