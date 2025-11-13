import ProjectDescription

fileprivate let nameAttribute: Template.Attribute = .required("name")

fileprivate let template = Template(
    description: "A template for a new UIKit application.",
    attributes: [
        nameAttribute,
    ],
    items: [
        .file(path: "App/Project.swift", templatePath: "project.stencil"),
        .file(path: "App/Sources/AppDelegate.swift", templatePath: "appDelegate.stencil"),
        .file(path: "App/Sources/SceneDelegate.swift", templatePath: "sceneDelegate.stencil"),
        .file(path: "App/Resources/Base.lproj/LaunchScreen.storyboard", templatePath: "launchScreen.stencil"),
        .file(path: "App/Resources/Assets.xcassets/Contents.json", templatePath: "assets_root.stencil"),
        .file(path: "App/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json", templatePath: "assets_appicon.stencil"),
        .file(path: "App/Resources/Assets.xcassets/AccentColor.colorset/Contents.json", templatePath: "assets_accentcolor.stencil")
    ]
)