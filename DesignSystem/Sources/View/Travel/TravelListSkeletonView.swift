public struct TravelListSkeletonView: View {
    @State private var shimmerPhase: CGFloat = -1.0

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 18) {
                ForEach(0..<5, id: \.self) { _ in
                    cardSkeleton()
                }
            }
            .padding(16)
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
                        .overlay(Color.gray2)
                    iconPlaceholder()
                    smallBar(width: 60)
                }

                HStack(spacing: 12) {
                    smallBar(width: 80)
                    smallBar(width: 50)
                    Spacer()
                }
            }
            .padding(20)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func capsulePlaceholder(width: CGFloat, height: CGFloat) -> some View {
        Capsule()
            .fill(Color.gray2)
            .frame(width: width, height: height)
            .skeletonShimmer(phase: shimmerPhase)
    }

    private func smallBar(width: CGFloat, height: CGFloat = 12) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.gray2)
            .frame(width: width, height: height)
            .skeletonShimmer(phase: shimmerPhase)
    }

    private func fullBar(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.gray2)
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
            .skeletonShimmer(phase: shimmerPhase)
    }

    private func iconPlaceholder(size: CGFloat = 18) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray2)
            .frame(width: size, height: size)
            .skeletonShimmer(phase: shimmerPhase)
    }
}
