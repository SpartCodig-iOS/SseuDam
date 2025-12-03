//
//  DashboardSkeletonView.swift
//  DesignSystem
//
//  Created by Wonji Suh on  12/03/25.
//

import SwiftUI

public struct DashboardSkeletonView: View {
  @State private var shimmerPhase: CGFloat = -1.0

  public init() {}

  public var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 16) {
        Spacer().frame(height: 10)

        placeholder(width: 78, height: 16)
          .padding(.top, 6)

        HStack(spacing: 28) {
          placeholder(width: 64, height: 14)
          placeholder(width: 64, height: 14)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)

        ForEach(0..<6, id: \.self) { _ in
          cardPlaceholder()
        }
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 32)
    }
    .background(Color.primary50.ignoresSafeArea())
    .onAppear {
      withAnimation(
        .linear(duration: 1.2)
          .repeatForever(autoreverses: false)
      ) {
        shimmerPhase = 1.2
      }
    }
  }
}

// MARK: - Building blocks
private extension DashboardSkeletonView {
  func cardPlaceholder() -> some View {
    VStack(alignment: .leading, spacing: 12) {
      placeholder(width: 52, height: 13)

      bar(height: 14)

      HStack(spacing: 10) {
        placeholder(width: 138, height: 12, color: .gray3)

        RoundedRectangle(cornerRadius: 2)
          .fill(.gray2.opacity(0.8))
          .frame(width: 10, height: 12)
          .skeletonShimmer(phase: shimmerPhase)

        placeholder(width: 40, height: 12, color: .gray3)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 14)
        .fill(.gray1)
    )
  }

  func placeholder(width: CGFloat, height: CGFloat, radius: CGFloat = 4, color: Color = .gray2) -> some View {
    RoundedRectangle(cornerRadius: radius)
      .fill(color)
      .frame(width: width, height: height)
      .skeletonShimmer(phase: shimmerPhase)
  }

  func bar(height: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: 4)
      .fill(.gray3)
      .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
      .skeletonShimmer(phase: shimmerPhase)
  }
}

#Preview {
  DashboardSkeletonView()
}
