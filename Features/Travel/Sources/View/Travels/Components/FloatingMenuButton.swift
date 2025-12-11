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
            if isOpen {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.gray7)
                    .frame(width: 52, height: 52)
                    .background(Color.appWhite)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

            } else {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.primary500)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
        }
    }
}
