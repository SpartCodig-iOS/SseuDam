import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies(
        [
            // MARK: - Architecture
            .remote(url: "https://github.com/pointfreeco/swift-composable-architecture.git", requirement: .upToNextMajor(from: "1.15.0")),
            .remote(url: "https://github.com/johnpatrickmorgan/TCACoordinators.git", requirement: .upToNextMajor(from: "0.10.0")),

            // MARK: - Networking
            .remote(url: "https://github.com/Alamofire/Alamofire.git", requirement: .upToNextMajor(from: "5.9.0")),
        ],
        productTypes: [
            // Architecture
            "ComposableArchitecture": .framework,
            "TCACoordinators": .framework,

            // Networking
            "Alamofire": .framework,
        ]
    ),
    platforms: [.iOS]
)
