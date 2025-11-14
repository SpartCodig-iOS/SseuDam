// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "ComposableArchitecture": .framework,
        "TCACoordinators": .framework,
        "Moya": .framework
    ]
)
#endif

let package = Package(
    name: "SseuDam",
    dependencies: [
        // MARK: - Architecture
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.18.0"),
        .package(url: "https://github.com/johnpatrickmorgan/TCACoordinators.git", from: "0.10.0"),

        // MARK: - Networking
        .package(url: "https://github.com/Moya/Moya.git", exact: "15.0.3")
    ]
)
