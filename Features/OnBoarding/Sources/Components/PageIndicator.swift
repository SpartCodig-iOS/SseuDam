//
//  PageIndicator.swift
//  OnBoardingFeature
//
//  Created by Wonji Suh  on 12/15/25.
//

import SwiftUI
import DesignSystem

public struct PageIndicator<P: Hashable>: View {
  private let current: P
  private let all: [P]

  public init(
    current: P,
    all: [P]
  ) {
    self.current = current
    self.all = all
  }

  public var body: some View {
    HStack(spacing: 10) {
      ForEach(Array(all.enumerated()), id: \.element) { _, page in
        if page == current {
          Capsule()
            .frame(width: 30, height: 8)
            .foregroundStyle(.primary500)
        } else {
          Circle()
            .frame(width: 8, height: 8)
            .foregroundStyle(.gray4)
        }
      }
    }
    .animation(.easeInOut(duration: 0.2), value: current)
  }
}
