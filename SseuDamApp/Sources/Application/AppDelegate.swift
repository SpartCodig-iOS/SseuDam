//
//  AppDelegate.swift
//  SseuDamApp
//
//  Created by Wonji Suh  on 12/8/25.
//

import UIKit
import UserNotifications

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
      print("📮 APNs Device Token:", tokenString)
    }

    // APNs 토큰 실패
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("📮 Failed to register for remote notifications:", error)
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
        print("🔔 Notification tapped:", userInfo)
        completionHandler()
    }
}
