import ProjectDescription

fileprivate let template = Template(
    description: "A template for a new Domain module.",
    attributes: [],
    items: [
        .file(path: "Domain/Project.swift", templatePath: "project.stencil"),
        .file(path: "Domain/Sources/Entity/SampleEntity.swift", templatePath: "sampleEntity.stencil"),
        .file(path: "Domain/Sources/UseCase/SampleUseCase.swift", templatePath: "sampleUseCase.stencil"),
        .file(path: "Domain/Sources/Repository/SampleRepositoryInterface.swift", templatePath: "sampleRepository.stencil"),
        .file(path: "Domain/Tests/SampleUseCaseTests.swift", templatePath: "sampleTests.stencil")
    ]
)