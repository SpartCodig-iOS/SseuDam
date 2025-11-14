import ProjectDescription

fileprivate let nameAttribute: Template.Attribute = .required("name")

fileprivate let template = Template(
    description: "A template for a new Feature module with SwiftUI demo app.",
    attributes: [
        nameAttribute,
    ],
    items: [
        // Project configuration
        .file(path: "Features/{{ name }}/Project.swift", templatePath: "project.stencil"),

        // Feature module files
        .file(path: "Features/{{ name }}/Sources/{{ name }}View.swift", templatePath: "view.stencil"),

        // Demo app files
        .file(path: "Features/{{ name }}/Demo/Sources/{{ name }}DemoApp.swift", templatePath: "demoApp.stencil"),
        .file(path: "Features/{{ name }}/Demo/Resources/LaunchScreen.storyboard", templatePath: "launchScreen.stencil")
    ]
)