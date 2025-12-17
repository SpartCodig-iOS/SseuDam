//
//  TravelListSkeletonView.swift
//  DesignSystem
//
//  Created by 김민희 on 12/15/25.
//

import SwiftUI

/// 여행 카드 리스트가 로딩될 때 TravelCardView의 형태를 흉내 내는 스켈레톤 뷰.
public struct TravelListSkeletonView: View {
    @State private var shimmerPhase: CGFloat = -1.0

    public init() {}

    public var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 18) {
                ForEach(0..<5, id: \.self) { _ in
                    cardSkeleton()
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(
                .linear(duration: 1.8)
                    .repeatForever(autoreverses: false)
            ) {
                shimmerPhase = 1.2
            }
        }
    }

    private func cardSkeleton() -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primary100)

            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appWhite)
                .offset(x: 5)

            VStack(alignment: .leading, spacing: 12) {
                capsulePlaceholder(width: 56, height: 18)

                fullBar(height: 20)

                HStack(spacing: 12) {
                    iconPlaceholder()
                    smallBar(width: 120)
                    Divider()
                        .frame(width: 1, height: 16)
                        .overlay(Color.gray1)
                    iconPlaceholder()
                    smallBar(width: 60)
                }
            }
            .padding(20)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func capsulePlaceholder(width: CGFloat, height: CGFloat) -> some View {
        Capsule()
            .fill(Color.gray1)
            .frame(width: width, height: height)
            .skeletonShimmer(phase: shimmerPhase)
    }

    private func smallBar(width: CGFloat, height: CGFloat = 12) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.gray1)
            .frame(width: width, height: height)
            .skeletonShimmer(phase: shimmerPhase)
    }

    private func fullBar(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.gray1)
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
            .skeletonShimmer(phase: shimmerPhase)
    }

    private func iconPlaceholder(size: CGFloat = 18) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray1)
            .frame(width: size, height: size)
            .skeletonShimmer(phase: shimmerPhase)
    }
}

#Preview {
    TravelListSkeletonView()
}
