import ProjectDescription

// MARK: - Project Environment
public enum Environment {
    // MARK: - App Configuration
    public static let appName = "SseuDam"
    public static let organizationName = "com.testdev"
    public static let deploymentTarget: DeploymentTargets = .iOS("17.0")

    // MARK: - Platform
    public static let platform: Platform = .iOS
    public static let destinations: Destinations = .iOS

    // MARK: - Build Configuration
    public static let configurations: [Configuration] = [
        .debug(name: "Debug"),
        .release(name: "Release")
    ]

    // MARK: - Bundle Identifier
    public static func bundleId(for moduleName: String) -> String {
        return "\(organizationName).\(moduleName.lowercased())"
    }

    // MARK: - Schemes
    public static func makeScheme(name: String, targets: [String]) -> Scheme {
        return Scheme.scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: targets.map { TargetReference(stringLiteral: $0) }),
            testAction: .targets(
                targets.map { TestableTarget(stringLiteral: $0) },
                configuration: .debug,
                options: .options(coverage: true)
            ),
            runAction: .runAction(configuration: .debug),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: .profileAction(configuration: .release),
            analyzeAction: .analyzeAction(configuration: .debug)
        )
    }
}
