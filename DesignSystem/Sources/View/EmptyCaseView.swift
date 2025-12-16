//
//  EmptyCaseView.swift
//  DesignSystem
//
//  Created by 홍석현 on 12/16/25.
//

import SwiftUI

public struct EmptyCaseView: View {
    private let image: ImageAsset
    private let message: String

    public init(image: ImageAsset, message: String) {
        self.image = image
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(asset: image)
                .resizable()
                .frame(width: 167, height: 167)
            Text(message)
                .font(.app(.title3, weight: .medium))
                .foregroundStyle(Color.gray6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyCaseView(image: .expenseEmpty, message: "아직 지출이 없어요")
}
