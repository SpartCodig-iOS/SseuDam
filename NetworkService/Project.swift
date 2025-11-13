import ProjectDescription

let project = Project(
    name: "NetworkService",
    targets: [
        .target(
            name: "NetworkService",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.testdev.networkservice",
            sources: ["Sources/**"],
            dependencies: []
        )
    ]
)