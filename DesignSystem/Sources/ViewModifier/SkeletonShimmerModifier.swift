//
//  SkeletonShimmerModifier.swift
//  DesignSystem
//
//  Created by Wonji Suh on  12/03/25.
//

import SwiftUI

/// Shimmer effect used across skeleton loading views.
public extension View {
  func skeletonShimmer(phase: CGFloat) -> some View {
    overlay(
      GeometryReader { proxy in
        LinearGradient(
          colors: [
            .gray2.opacity(0.2),
            .gray2.opacity(0.4),
            .gray2.opacity(0.2)
          ],
          startPoint: .leading,
          endPoint: .trailing
        )
        .frame(width: proxy.size.width * 0.8)
        .offset(x: proxy.size.width * phase)
      }
      .clipped()
    )
    .mask(self)
  }
}
