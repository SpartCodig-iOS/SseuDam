import ProjectDescription

public extension InfoPlist {
    /// SwiftUI App용 기본 Info.plist
  static var defaultSwiftUIApp: InfoPlist {
      .extendingDefault(with: [
        "UILaunchScreen": .dictionary([
          "UILaunchScreen": .dictionary([:])
        ]),
        "SUPABASE_URL": .string("$(SUPABASE_URL)"),
        "SUPABASE_KEY": .string("$(SUPABASE_KEY)"),
        "GOOGLE_IOS_CLIENT_ID": .string("$(GOOGLE_IOS_CLIENT_ID)"),
        "GOOGLE_SERVER_CLIENT_ID": .string("$(GOOGLE_SERVER_CLIENT_ID)"),
        "GOOGLE_REVERSED_IOS_CLIENT_ID": .string("$(GOOGLE_REVERSED_IOS_CLIENT_ID)"),
        "KAKAO_NATIVE_APP_KEY": .string("$(KAKAO_NATIVE_APP_KEY)"),
        "KAKAO_REST_API_KEY": .string("$(KAKAO_REST_API_KEY)"),
        "MIXPANEL_TOKEN": .string("$(MIXPANEL_TOKEN)"),
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
          ]),
          .dictionary([
            "CFBundleURLName": .string("kakao-login"),
            "CFBundleURLSchemes": .array([
              .string("kakao$(KAKAO_NATIVE_APP_KEY)")
            ])
          ])

        ]),
        "NSPhotoLibraryUsageDescription": .string("We use your photo library to update your profile image."),
        "com.apple.developer.associated-domains": .array([
          .string("applinks:sseudam.up.railway.app"),
        ]),
        "UISupportedInterfaceOrientations": .array([
          .string("UIInterfaceOrientationPortrait")
        ]),
        "UIUserInterfaceStyle": .string("Light"),
        "CFBundleShortVersionString": .string(Environment.mainAppVersion),
        "ITSAppUsesNonExemptEncryption": .boolean(false),
        "CFBundleVersion": .string(Environment.mainAppBuildVersion),
        "LSApplicationQueriesSchemes": .array([
              .string("kakaokompassauth"), // 카카오톡 로그인
              .string("kakaolink"),        // 카카오톡 공유
            ]),
        "CFBundleName": .string("쓰담")


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
