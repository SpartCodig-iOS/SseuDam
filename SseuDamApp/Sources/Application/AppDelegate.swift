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
import Firebase
import FirebaseAnalytics
import ComposableArchitecture

final class AppDelegate: NSObject, UIApplicationDelegate, @MainActor UNUserNotificationCenterDelegate {
  @Dependency(\.deeplinkRouter) var deeplinkRouter

  @MainActor
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {

#if DEBUG
    setenv("FIRAnalyticsDebugEnabled", "1", 1)
    setenv("FIRDebugEnabled", "1", 1)
#endif

    FirebaseApp.configure()
    Analytics.setAnalyticsCollectionEnabled(true)
    let center = UNUserNotificationCenter.current()
    center.delegate = self

    center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if let error = error {
        #logDebug("🔔 Notification auth error:", error)
        return
      }

      guard granted else {
        #logDebug("🔔 Notification permission not granted")
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

    Task.detached(priority: .utility) {
      do {
        try await Task.sleep(for: .seconds(0.3))
        _ = try await repo.registerDeviceToken(token: tokenString)
      } catch {
        #logDebug("🔔 Failed to register device token: \(error.localizedDescription)")
      }
    }
  }

  // APNs 토큰 실패
  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {

  }

  // 포그라운드 알림 표시
  @MainActor
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .badge, .sound])
  }

  // 알림 터치 처리
  @MainActor
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo

    if let urlString = self.deeplinkRouter.extractDeepLink(from: userInfo) {
      #logDebug("🔗 Processing push notification deep link: \(urlString)")

      // UserDefaults에도 저장 (앱이 종료된 상태에서 푸시 알림을 탭한 경우 대비)
      UserDefaults.standard.set(urlString, forKey: UserDefaultsKey.pendingPushDeepLink.rawValue)

      NotificationCenter.default.post(
        name: .pushNotificationDeepLink,
        object: nil,
        userInfo: [
          "url": urlString,
          "deeplink_type": "push"
        ]
      )
    }

    completionHandler()
  }

  /// 여러 가능한 경로에서 딥링크 문자열을 추출
//  nonisolated private static func extractDeepLink(from userInfo: [AnyHashable: Any]) -> String? {
//    // 1) 단일 문자열 필드 우선
//    let stringKeys = ["deeplink", "url"]
//    for key in stringKeys {
//      if let url = userInfo[key] as? String { return url }
//    }
//
//    // 2) 중첩 객체에서 url 필드 찾기 (호환 키: deeplink, data, custom)
//    let containerKeys = ["deeplink", "data", "custom"]
//    for key in containerKeys {
//      guard let container = userInfo[key] as? [String: Any],
//            let url = container["url"] as? String else { continue }
//      return url
//    }
//
//    #logDebug("❌ No deep link found in push notification")
//    #logDebug("Available keys: \(userInfo.keys)")
//    return nil
//  }
}

extension Notification.Name {
  static let pushNotificationDeepLink = Notification.Name("pushNotificationDeepLink")
}

enum UserDefaultsKey: String {
  case pendingPushDeepLink
}
