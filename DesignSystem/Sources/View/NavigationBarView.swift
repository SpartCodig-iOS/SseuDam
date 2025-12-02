//
//  NavigationBarView.swift
//  DesignSystem
//
//  Created by 홍석현 on 12/2/25.
//

import SwiftUI

public struct NavigationBarView<TrailingContent: View>: View {
    let title: String
    let onBackTapped: () -> Void
    let trailingContent: TrailingContent

    public init(
        title: String,
        onBackTapped: @escaping () -> Void,
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        self.title = title
        self.onBackTapped = onBackTapped
        self.trailingContent = trailingContent()
    }

    public var body: some View {
        HStack(spacing: 10) {
            Button(action: onBackTapped) {
                Image(asset: .chevronLeft)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.vertical, 20)
                    .contentShape(Rectangle())
                    .foregroundStyle(Color.black)
            }
            .buttonStyle(.plain)

            Text(title)
                .font(.app(.title1, weight: .semibold))

            Spacer()

            trailingContent
                .frame(minWidth: 24, minHeight: 64)
        }
    }
}

// MARK: - Convenience init without trailing content
extension NavigationBarView where TrailingContent == EmptyView {
    public init(
        title: String,
        onBackTapped: @escaping () -> Void
    ) {
        self.title = title
        self.onBackTapped = onBackTapped
        self.trailingContent = EmptyView()
    }
}

// MARK: - Common trailing button styles
public struct TrailingButton: View {
    let action: () -> Void
    let content: Content

    public enum Content {
        case icon(ImageAsset)
        case text(String)
    }

    public init(icon: ImageAsset, action: @escaping () -> Void) {
        self.action = action
        self.content = .icon(icon)
    }

    public init(text: String, action: @escaping () -> Void) {
        self.action = action
        self.content = .text(text)
    }

    public var body: some View {
        Button(action: action) {
            Group {
                switch content {
                case .icon(let asset):
                    Image(asset: asset)
                        .resizable()
                        .frame(width: 24, height: 24)

                case .text(let text):
                    Text(text)
                        .font(.app(.body, weight: .medium))
                }
            }
            .padding(.vertical, 20)
            .contentShape(Rectangle())
            .foregroundStyle(Color.black)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        // Settings 아이콘 버튼
        NavigationBarView(
            title: "오사카 여행",
            onBackTapped: {}
        ) {
            TrailingButton(icon: .settings) {}
        }

        // 텍스트 버튼
        NavigationBarView(
            title: "지출 수정",
            onBackTapped: {}
        ) {
            TrailingButton(text: "삭제") {}
        }

        // 트레일링 버튼 없음
        NavigationBarView(
            title: "지출 추가",
            onBackTapped: {}
        )
    }
}
