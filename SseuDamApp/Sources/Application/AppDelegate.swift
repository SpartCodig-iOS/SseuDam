//
//  AppDelegate.swift
//  SseuDamApp
//
//  Created by Wonji Suh  on 12/8/25.
//

import UIKit
import UserNotifications
import LogMacro
import Data


@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("🔔 Notification auth error:", error)
                return
            }

            guard granted else {
                print("🔔 Notification permission not granted")
                return
            }

            Task { @MainActor in
                UIApplication.shared.registerForRemoteNotifications()
            }
        }

        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return false
    }

    // APNs 토큰 성공
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        UserDefaults.standard.set(tokenString, forKey: "Token")
      let repo = AuthRepository()

      Task {
        let repodata =  try await repo.registerDeviceToken(token: tokenString)
        #logDebug("토큰 결과 값", repodata)
      }
    }

    // APNs 토큰 실패
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {

    }

    // 포그라운드 알림 표시
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }

    // 알림 터치 처리
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        if let urlString = Self.extractDeepLink(from: userInfo) {
            #logDebug("🔗 Processing push notification deep link: \(urlString)")

            // UserDefaults에도 저장 (앱이 종료된 상태에서 푸시 알림을 탭한 경우 대비)
            UserDefaults.standard.set(urlString, forKey: "pendingPushDeepLink")

            // 메인 스레드에서 딥 링크 처리
            Task { @MainActor in
                NotificationCenter.default.post(
                    name: .pushNotificationDeepLink,
                    object: nil,
                    userInfo: ["url": urlString]
                )
            }
        }

        completionHandler()
    }

    /// 여러 가능한 경로에서 딥링크 문자열을 추출
    nonisolated private static func extractDeepLink(from userInfo: [AnyHashable: Any]) -> String? {
        if let url = userInfo["deeplink"] as? String { return url }
        if let deeplinkData = userInfo["deeplink"] as? [String: Any],
           let url = deeplinkData["url"] as? String { return url }
        if let url = userInfo["url"] as? String { return url }
        if let customData = userInfo["custom"] as? [String: Any],
           let url = customData["url"] as? String { return url }
        if let data = userInfo["data"] as? [String: Any],
           let url = data["url"] as? String { return url }

        #logDebug("❌ No deep link found in push notification")
        #logDebug("Available keys: \(userInfo.keys)")
        return nil
    }
}

extension Notification.Name {
    static let pushNotificationDeepLink = Notification.Name("pushNotificationDeepLink")
}
