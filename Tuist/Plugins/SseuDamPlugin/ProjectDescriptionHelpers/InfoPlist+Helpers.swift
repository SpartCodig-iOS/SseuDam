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
        ]),
        "NSPhotoLibraryUsageDescription": .string("We use your photo library to update your profile image."),
        "UISupportedInterfaceOrientations": .array([
          .string("UIInterfaceOrientationPortrait")
        ]),
        "UIUserInterfaceStyle": .string("Light")

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
