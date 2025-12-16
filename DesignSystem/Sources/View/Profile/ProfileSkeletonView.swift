//
//  ProfileSkeletonView.swift
//  DesignSystem
//
//  Created by Wonji Suh on  12/03/25.
//

import SwiftUI

public struct ProfileSkeletonView: View {
  @State private var shimmerPhase: CGFloat = -1.0

  public init() {}

  public var body: some View {
    ZStack {
      Color.primary50.ignoresSafeArea()

      VStack(spacing: 0) {
        navPlaceholder()

        Spacer().frame(height: 32)

        headerPlaceholder()

        Spacer().frame(height: 32)

        Divider()
          .background(.gray2.opacity(0.4))
          .padding(.horizontal, 16)

        Spacer().frame(height: 32)

        sectionPlaceholder()
          .padding(.horizontal, 16)

        Spacer().frame(height: 12)

        cardPlaceholder()
          .padding(.horizontal, 16)

        Spacer().frame(height: 28)

        sectionPlaceholder()
          .padding(.horizontal, 16)

        Spacer().frame(height: 12)

        cardPlaceholder()
          .padding(.horizontal, 16)

        cardPlaceholder()
          .padding(.horizontal, 16)

        Spacer()
      }
    }
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
private extension ProfileSkeletonView {
  func navPlaceholder() -> some View {
    HStack(spacing: 12) {
      RoundedRectangle(cornerRadius: 4)
        .fill(.gray2)
        .frame(width: 18, height: 18)
        .shimmer(phase: shimmerPhase)

      RoundedRectangle(cornerRadius: 6)
        .fill(.gray2)
        .frame(width: 64, height: 16)
        .shimmer(phase: shimmerPhase)

      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.top, 12)
  }

  func headerPlaceholder() -> some View {
    VStack(spacing: 14) {
      Circle()
        .fill(.gray2)
        .frame(width: 110, height: 110)
        .shimmer(phase: shimmerPhase)

      RoundedRectangle(cornerRadius: 4)
        .fill(.gray2)
        .frame(width: 46, height: 14)
        .shimmer(phase: shimmerPhase)

      RoundedRectangle(cornerRadius: 6)
        .fill(.gray2)
        .frame(width: 190, height: 16)
        .shimmer(phase: shimmerPhase)
    }
  }

  func sectionPlaceholder() -> some View {
    HStack {
      RoundedRectangle(cornerRadius: 4)
        .fill(.gray2)
        .frame(width: 72, height: 14)
        .shimmer(phase: shimmerPhase)
      Spacer()
    }
  }

  func cardPlaceholder() -> some View {
    VStack(spacing: 0) {
      ForEach(0..<2, id: \.self) { index in
        HStack(spacing: 12) {
          Circle()
            .fill(.gray2)
            .frame(width: 18, height: 18)
            .shimmer(phase: shimmerPhase)

          RoundedRectangle(cornerRadius: 6)
            .fill(.gray2)
            .frame(height: 14)
            .shimmer(phase: shimmerPhase)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)

        if index == 0 {
          Divider()
            .background(.gray2.opacity(0.35))
            .padding(.horizontal, 12)
        }
      }
    }
    .padding(.vertical, 14)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(.white)
        .shadow(color: .shadow.opacity(0.08), radius: 4, x: 1, y: 2)
    )
  }
}

// MARK: - Shimmer
private extension View {
  func shimmer(phase: CGFloat) -> some View {
    self
      .overlay(
        GeometryReader { proxy in
          LinearGradient(
            colors: [
              .gray2.opacity(0.2),
              .white.opacity(0.5),
              .gray2.opacity(0.2)
            ],
            startPoint: .leading,
            endPoint: .trailing
          )
          .frame(width: proxy.size.width * 1.2)
          .offset(x: proxy.size.width * phase)
        }
        .clipped()
      )
      .mask(self)
  }
}
