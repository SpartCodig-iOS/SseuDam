import ProjectDescription

let template = Template(
    description: "A template for a new DesignSystem module.",
    attributes: [],
    items: [
        .file(path: "DesignSystem/Project.swift", templatePath: "project.stencil"),
        .file(path: "DesignSystem/Sources/Empty.swift", templatePath: "empty.stencil")
    ]
)