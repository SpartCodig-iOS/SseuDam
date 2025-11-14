import ProjectDescription

public extension InfoPlist {
    /// SwiftUI App용 기본 Info.plist
    static var defaultSwiftUIApp: InfoPlist {
        .extendingDefault(with: [
            "UILaunchStoryboardName": "LaunchScreen"
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
