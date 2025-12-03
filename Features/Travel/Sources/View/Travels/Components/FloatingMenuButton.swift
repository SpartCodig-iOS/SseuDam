//
//  FloatingMenuButton.swift
//  TravelFeature
//
//  Created by 김민희 on 12/2/25.
//

import SwiftUI
import DesignSystem

struct FloatingMenuButton: View {
    let isOpen: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(assetName: isOpen ? "xmark" : "plus")
                .resizable()
                .scaledToFit()
                .frame(height: isOpen ?  12 : 14)
                .foregroundStyle(isOpen ? Color.gray7 : Color.appWhite)
                .padding(isOpen ? 20 : 19)
                .background(isOpen ? Color.appWhite : Color.primary500)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
        }
    }
}
