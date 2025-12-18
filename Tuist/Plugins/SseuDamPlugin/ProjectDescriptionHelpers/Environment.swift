import ProjectDescription

// MARK: - Project Environment
public enum Environment {
    // MARK: - App Configuration
    public static let appName = "Sseudam"
    public static let organizationName = "io.sseudam.co"
    public static let deploymentTarget: DeploymentTargets = .iOS("17.0")
    public static let organizationTeamId = "N94CS4N6VR"

    // MARK: - Version Management
    public static let mainAppVersion = "1.0.4"
    public static let mainAppBuildVersion = "26"
    public static let demoAppVersion = "0.1.0"  // Demo app용 별도 버전

    // MARK: - Platform
    public static let platform: Platform = .iOS
  public static let destinations: Destinations = [.iPhone]

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

    /// Demo 앱 전용 Scheme 생성 (실행 가능한 앱)
    public static func makeDemoScheme(name: String, executableTarget: String) -> Scheme {
        return Scheme.scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: [TargetReference(stringLiteral: executableTarget)]),
            runAction: .runAction(
                configuration: .debug,
                executable: TargetReference(stringLiteral: executableTarget)
            ),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: .profileAction(
                configuration: .release,
                executable: TargetReference(stringLiteral: executableTarget)
            ),
            analyzeAction: .analyzeAction(configuration: .debug)
        )
    }
}
