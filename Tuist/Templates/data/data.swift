import ProjectDescription

fileprivate let template = Template(
    description: "A template for a new Data module.",
    attributes: [],
    items: [
        .file(path: "Data/Project.swift", templatePath: "project.stencil"),
        .file(path: "Data/Sources/Empty.swift", templatePath: "empty.stencil")
    ]
)