import ProjectDescription

let project = Project(
    name: "SseuDamApp",
    targets: [
        .target(
            name: "SseuDamApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.testdev.sseudamapp",
            infoPlist: .extendingDefault(with: [
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
            ]),
            sources: ["Sources/**"],
            resources: ["Resources/**"]
        )
    ]
)