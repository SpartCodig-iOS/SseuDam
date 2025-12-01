import ProjectDescription

fileprivate let template = Template(
    description: "A template for a new NetworkService module.",
    attributes: [],
    items: [
        .file(path: "NetworkService/Project.swift", templatePath: "project.stencil"),
        .file(path: "NetworkService/Sources/Empty.swift", templatePath: "empty.stencil")
    ]
)
