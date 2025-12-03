//
//  TravelSettingSkeletonView.swift
//  DesignSystem
//
//  Created by Wonji Suh on  12/03/25.
//

import SwiftUI

public struct TravelSettingSkeletonView: View {
  @State private var shimmerPhase: CGFloat = -1.0

  public init() {}

  public var body: some View {
    ScrollView(showsIndicators: false) {
      VStack(alignment: .leading, spacing: 16) {
        Spacer().frame(height: 10)

        headerPlaceholders()

        basicSectionCard()

        sectionHeader()

        memberCard()

        manageHeader()

        manageCard()
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 28)
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

// MARK: - Layout pieces
private extension TravelSettingSkeletonView {
  func headerPlaceholders() -> some View {
    VStack(alignment: .leading, spacing: 12) {
      placeholder(width: 54, height: 14)

      HStack {
        placeholder(width: 64, height: 14)
        Spacer()
        placeholder(width: 16, height: 16, radius: 4)
      }
    }
  }

  func basicSectionCard() -> some View {
    VStack(alignment: .leading, spacing: 14) {
      placeholder(width: 52, height: 12)

      fullBar(height: 14)

      HStack(alignment: .top, spacing: 12) {
        doubleLineColumn()

        Divider()
          .frame(width: 1, height: 46)
          .overlay(Color.gray1)

        doubleLineColumn()
      }

      Divider().overlay(Color.gray1)

      labelAndValue()

      Divider().overlay(Color.gray1)

      VStack(alignment: .leading, spacing: 10) {
        placeholder(width: 40, height: 10)
        fullBar(height: 14)
        smallBar()
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.appWhite)
        .shadow(color: .shadow.opacity(0.05), radius: 8, x: 0, y: 2)
    )
  }

  func sectionHeader() -> some View {
    HStack {
      placeholder(width: 64, height: 13)
      Spacer()
      placeholder(width: 18, height: 18, radius: 4)
    }
  }

  func memberCard() -> some View {
    VStack(spacing: 12) {
      ForEach(0..<3, id: \.self) { _ in
        fullBar(height: 20)
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.appWhite)
        .shadow(color: .shadow.opacity(0.05), radius: 8, x: 0, y: 2)
    )
  }

  func manageHeader() -> some View {
    placeholder(width: 68, height: 13)
  }

  func manageCard() -> some View {
    VStack(spacing: 0) {
      manageRow()

      Divider()
        .overlay(Color.gray1)
        .padding(.horizontal, 2)

      manageRow()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.appWhite)
        .shadow(color: .shadow.opacity(0.05), radius: 8, x: 0, y: 2)
    )
  }
}

// MARK: - Building blocks
private extension TravelSettingSkeletonView {
  func placeholder(width: CGFloat, height: CGFloat, radius: CGFloat = 6) -> some View {
    RoundedRectangle(cornerRadius: radius)
      .fill(Color.gray2)
      .frame(width: width, height: height)
      .skeletonShimmer(phase: shimmerPhase)
  }

  func fullBar(height: CGFloat) -> some View {
    RoundedRectangle(cornerRadius: 6)
      .fill(Color.gray2)
      .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
      .skeletonShimmer(phase: shimmerPhase)
  }

  func smallBar(width: CGFloat = 110) -> some View {
    RoundedRectangle(cornerRadius: 4)
      .fill(Color.gray2)
      .frame(width: width, height: 10)
      .skeletonShimmer(phase: shimmerPhase)
  }

  func doubleLineColumn() -> some View {
    VStack(alignment: .leading, spacing: 8) {
      smallBar(width: 38)
      smallBar(width: 74)
    }
  }

  func labelAndValue() -> some View {
    VStack(alignment: .leading, spacing: 10) {
      smallBar(width: 28)
      fullBar(height: 14)
    }
  }

  func manageRow() -> some View {
    HStack {
      smallBar(width: 140)
      Spacer()
    }
    .padding(.vertical, 10)
  }
}

#Preview {
  TravelSettingSkeletonView()
}
