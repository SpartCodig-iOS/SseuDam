//
//  ToastView.swift
//  DesignSystem
//
//  Created by Wonji Suh on 11/28/25.
//

import SwiftUI

public struct ToastView: View {
    let toast: ToastType
    @StateObject private var toastManager = ToastManager.shared

    public init(toast: ToastType) {
        self.toast = toast
    }

    public var body: some View {
      HStack(alignment: .center, spacing: 4) {
            // 에러 아이콘 (X 표시)
        Image(asset: .xmark)
          .resizable()
          .scaledToFit()
          .frame(width: 12, height: 12)

            // 메시지
            Text(toast.message)
                .font(.app(.body, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

        }
        .padding(.horizontal, 20)
        .padding(.vertical, 11)
        .background(.gray5)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Toast Overlay Modifier
public struct ToastOverlay: ViewModifier {
    @StateObject private var toastManager = ToastManager.shared

    public func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let toast = toastManager.currentToast {
                    ToastView(toast: toast)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        .opacity(toastManager.isVisible ? 1 : 0)
                        .offset(y: toastManager.isVisible ? 0 : 100)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                        .allowsHitTesting(toastManager.isVisible)
                }
            }
    }
}

// MARK: - View Extension
public extension View {
    func toastOverlay() -> some View {
        modifier(ToastOverlay())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Button("성공 토스트") {
            ToastManager.shared.showSuccess("로그인에 성공했습니다!")
        }

        Button("에러 토스트") {
            ToastManager.shared.showError("인증에 실패했어요. 다시 시도해주세요..")
        }

        Button("경고 토스트") {
            ToastManager.shared.showWarning("네트워크 연결을 확인해주세요.")
        }

        Button("정보 토스트") {
            ToastManager.shared.showInfo("새로운 업데이트가 있습니다.")
        }
    }
    .padding()
    .toastOverlay()
}
