import ProjectDescription

public extension InfoPlist {
    /// SwiftUI App용 기본 Info.plist
  static var defaultSwiftUIApp: InfoPlist {
      .extendingDefault(with: [
        "UILaunchScreen": .dictionary([
          "UILaunchScreen": .dictionary([:])
        ]),

        // 환경 변수 → Info.plist 로 흘려보내기
        "SUPERBASE_URL": .string("$(SUPERBASE_URL)"),
        "SUPERBASE_KEY": .string("$(SUPERBASE_KEY)"),
        "GOOGLE_IOS_CLIENT_ID": .string("$(GOOGLE_IOS_CLIENT_ID)"),
        "GOOGLE_SERVER_CLIENT_ID": .string("$(GOOGLE_SERVER_CLIENT_ID)"),
        "GOOGLE_REVERSED_IOS_CLIENT_ID": .string("$(GOOGLE_REVERSED_IOS_CLIENT_ID)"),
        // CFBundleURLTypes (네가 첫 번째에 쓴 구조 그대로)
        "CFBundleURLTypes": .array([
          .dictionary([
            "CFBundleURLName": .string("sseudam"),
            "CFBundleURLSchemes": .array([
              .string("sseudam")
            ])
          ]),
          .dictionary([
            "CFBundleURLName": .string("google-oauth"),
            "CFBundleURLSchemes": .array([
              .string("$(GOOGLE_REVERSED_IOS_CLIENT_ID)"),
            ])
          ])
        ])
      ])
    }

    /// UIKit App용 기본 Info.plist (deprecated - SwiftUI로 전환)
    @available(*, deprecated, message: "Use defaultSwiftUIApp instead")
    static var defaultApp: InfoPlist {
        .extendingDefault(with: [
            "UILaunchStoryboardName": "LaunchScreen",
            "UIApplicationSceneManifest": [
                "UIApplicationSupportsMultipleScenes": false,
                "UISceneConfigurations": [
                    "UIWindowSceneSessionRoleApplication": [
                        [
                            "UISceneConfigurationName": "Default Configuration",
                            "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                        ]
                    ]
                ]
            ]
        ])
    }
}
