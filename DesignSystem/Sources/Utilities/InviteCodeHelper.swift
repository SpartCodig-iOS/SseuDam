//
//  InviteCodeHelper.swift
//  DesignSystem
//
//  Created by Claude on 12/17/24.
//

import UIKit

/// 여행 초대 코드 복사 및 공유 기능을 제공하는 헬퍼
@MainActor
public enum InviteCodeHelper {

    /// 초대 코드를 클립보드에 복사
    /// - Parameter code: 복사할 초대 코드
    public static func copyToClipboard(_ code: String) {
        UIPasteboard.general.string = code
        ToastManager.shared.showSuccess("클립보드에 복사되었습니다.")
    }

    /// 딥링크를 시스템 공유 시트를 통해 공유
    /// - Parameter deepLink: 공유할 딥링크 URL
    public static func shareDeepLink(_ deepLink: URL) {
        let activityViewController = UIActivityViewController(
            activityItems: [deepLink],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
    }
}
