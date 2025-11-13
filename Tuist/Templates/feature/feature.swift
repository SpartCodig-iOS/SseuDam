import ProjectDescription

fileprivate let nameAttribute: Template.Attribute = .required("name")

fileprivate let template = Template(
    description: "A template for a new Feature module with demo app.",
    attributes: [
        nameAttribute,
    ],
    items: [
        // Project configuration
        .file(path: "Feature/{{ name }}/Project.swift", templatePath: "project.stencil"),
        
        // Feature module files
        .file(path: "Feature/{{ name }}/Sources/{{ name }}ViewController.swift", templatePath: "viewController.stencil"),
        
        // Demo app files
        .file(path: "Feature/{{ name }}/Demo/Sources/AppDelegate.swift", templatePath: "appDelegate.stencil"),
        .file(path: "Feature/{{ name }}/Demo/Sources/SceneDelegate.swift", templatePath: "sceneDelegate.stencil"),
        .file(path: "Feature/{{ name }}/Demo/Resources/LaunchScreen.storyboard", templatePath: "launchScreen.stencil")
    ]
)