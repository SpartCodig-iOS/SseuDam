import ProjectDescription

fileprivate let nameAttribute: Template.Attribute = .required("name")

fileprivate let template = Template(
    description: "A template for a new UIKit application.",
    attributes: [
        nameAttribute,
    ],
    items: [
        .file(path: "Project.swift", templatePath: "project.stencil"),
        .file(path: "Sources/AppDelegate.swift", templatePath: "appDelegate.stencil"),
        .file(path: "Sources/SceneDelegate.swift", templatePath: "sceneDelegate.stencil"),
        .file(path: "Resources/Base.lproj/LaunchScreen.storyboard", templatePath: "launchScreen.stencil"),
        .file(path: "Resources/Assets.xcassets/Contents.json", templatePath: "assets_root.stencil"),
        .file(path: "Resources/Assets.xcassets/AppIcon.appiconset/Contents.json", templatePath: "assets_appicon.stencil"),
        .file(path: "Resources/Assets.xcassets/AccentColor.colorset/Contents.json", templatePath: "assets_accentcolor.stencil")
    ]
)