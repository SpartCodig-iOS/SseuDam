//
//  FloatingActionButton.swift
//  DesignSystem
//
//  Created by 홍석현 on 11/30/25.
//

import SwiftUI

public struct FloatingActionButton: View {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
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

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()

        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingActionButton {
                    print("Add expense tapped")
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
}
