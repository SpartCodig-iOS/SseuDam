//
//  AsyncImage+Cache.swift
//  DesignSystem
//
//  Created by Wonji Suh on 12/16/25.
//

import SwiftUI

// MARK: - SwiftUI AsyncImage Replacement

/// 기존 SwiftUI.AsyncImage를 완전히 대체하는 typealias
/// 사용자는 전혀 모르지만 자동으로 캐싱됨
public typealias AsyncImage = DesignSystemAsyncImage

/// SwiftUI AsyncImage와 동일한 API를 제공하는 향상된 AsyncImage
public struct DesignSystemAsyncImage<Content: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content

    @State private var loadedImage: UIImage?
    @State private var isLoading: Bool = false
    @State private var loadError: Error?

    // MARK: - Initializers

    public init(
        url: URL?,
        scale: CGFloat = 1,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        // ImageCacheService 초기화 확인
        _ = autoSetup

        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }

    public var body: some View {
        Group {
            if let loadedImage {
                content(.success(Image(uiImage: loadedImage)))
            } else if isLoading {
                content(.empty)
            } else if loadError != nil {
                content(.failure(loadError!))
            } else {
                content(.empty)
            }
        }
        .task(id: url) {
            await loadImage()
        }
        .transaction { transcation in
          transcation.animation = transaction.animation
          transcation.disablesAnimations = transaction.disablesAnimations
          transcation.isContinuous = transaction.isContinuous
        }
    }

    private func loadImage() async {
        guard let url = url else {
            await MainActor.run {
                isLoading = false
                loadedImage = nil
                loadError = nil
            }
            return
        }

        await MainActor.run {
            isLoading = true
            loadError = nil
        }

        // 🚀 직접 ImageCacheService 사용으로 빠른 로딩!
        let image = await ImageCacheService.shared.image(for: url)

        await MainActor.run {
            isLoading = false
            loadedImage = image

            if image == nil {
                loadError = URLError(.resourceUnavailable)
            }
        }
    }

  private let autoSetup: Void = {
      Task {
          _ = ImageCacheService.shared
          await TransparentImageCaching.activate()
      }
  }()
}

// MARK: - Convenience Initializers

extension DesignSystemAsyncImage where Content == Image {
    public init(
        url: URL?,
        scale: CGFloat = 1
    ) {
        self.init(
            url: url,
            scale: scale,
            content: { phase in
                phase.image ?? Image(systemName: "photo")
            }
        )
    }
}

extension DesignSystemAsyncImage {
    public init<I: View, P: View>(
        url: URL?,
        scale: CGFloat = 1,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P> {
        self.init(url: url, scale: scale, transaction: transaction) { phase in
            if case .success(let image) = phase {
                content(image)
            } else {
                placeholder()
            }
        }
    }
}
