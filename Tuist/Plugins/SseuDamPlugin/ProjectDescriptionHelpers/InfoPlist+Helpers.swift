import ProjectDescription

public extension InfoPlist {
    /// SwiftUI App용 기본 Info.plist
  static var defaultSwiftUIApp: InfoPlist {
     .extendingDefault(with: [
       "UILaunchStoryboardName": "LaunchScreen",
       "CFBundleURLTypes": .array([
         .dictionary([
           "CFBundleURLSchemes": .array([
             .string("sseudam")
           ])
         ]),
         .dictionary([
           "CFBundleURLName": .string("com.googleusercontent.apps"),
           "CFBundleURLSchemes": .array([
             .string("$(GOOGLE_REVERSED_IOS_CLIENT_ID)"),
             .string("com.googleusercontent.apps.761238969842-o160r5m37bd7bai69hbbanph8jpq8v17")
           ])
         ])
       ]),
       "SUPERBASE_URL": .string("$(SUPERBASE_URL)"),
       "SUPERBASE_KEY": .string("$(SUPERBASE_KEY)"),
       "GOOGLE_SERVER_CLIENT_ID": .string("$(GOOGLE_SERVER_CLIENT_ID)"),
       "GOOGLE_IOS_CLIENT_ID": .string("$(GOOGLE_IOS_CLIENT_ID)")
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
