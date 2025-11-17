import ProjectDescription

// MARK: - Project Factory
public extension Project {
  /// Create an App project
  static func makeApp(
    name: String,
    dependencies: [TargetDependency] = [],
    resources: ResourceFileElements? = nil,
    infoPlist: InfoPlist = .defaultSwiftUIApp
  ) -> Project {
    return Project(
      name: name,
      targets: [
        .target(
          name: name,
          destinations: Environment.destinations,
          product: .app,
          bundleId: Environment.organizationName,
          deploymentTargets: Environment.deploymentTarget,
          infoPlist: infoPlist,
          sources: ["Sources/**"],
          resources: resources ?? ["Resources/**"],
          dependencies: dependencies,
          settings: .appMainSetting
        )
      ]
    )
  }

  /// Create a Framework project
  static func makeFramework(
    name: String,
    dependencies: [TargetDependency] = [],
    resources: ResourceFileElements? = nil,
    hasTests: Bool = false,
    settings: Settings? = nil
  ) -> Project {
    var targets: [Target] = [
      .target(
        name: name,
        destinations: Environment.destinations,
        product: .framework,
        bundleId: Environment.bundleId(for: name),
        deploymentTargets: Environment.deploymentTarget,
        sources: ["Sources/**"],
        resources: resources,
        dependencies: dependencies,
        settings: settings
      )
    ]

    if hasTests {
      targets.append(
        .target(
          name: "\(name)Tests",
          destinations: Environment.destinations,
          product: .unitTests,
          bundleId: Environment.bundleId(for: "\(name)Tests"),
          deploymentTargets: Environment.deploymentTarget,
          sources: ["Tests/**"],
          dependencies: [
            .target(name: name)
          ]
        )
      )
    }

    return Project(name: name, targets: targets)
  }


  static func makeFeature(
    name: FeatureName,
    dependencies: [TargetDependency] = [],
    hasTests: Bool = false
  ) -> Project {
    return makeFeature(
      name: name.rawValue,
      dependencies: dependencies,
      hasTests: hasTests
    )
  }

  /// Create a Feature module with Demo app (using String)
  static func makeFeature(
    name: String,
    dependencies: [TargetDependency] = [],
    hasTests: Bool = false
  ) -> Project {
    var targets: [Target] = [
      // Feature Framework
      .target(
        name: "\(name)Feature",
        destinations: Environment.destinations,
        product: .framework,
        bundleId: Environment.bundleId(for: "\(name)Feature"),
        deploymentTargets: Environment.deploymentTarget,
        sources: ["Sources/**"],
        dependencies: dependencies
      ),
      // Demo App
      .target(
        name: "\(name)FeatureDemo",
        destinations: Environment.destinations,
        product: .app,
        bundleId: Environment.bundleId(for: "\(name)Feature.demo"),
        deploymentTargets: Environment.deploymentTarget,
        infoPlist: .defaultSwiftUIApp,
        sources: ["Demo/Sources/**"],
        resources: ["Demo/Resources/**"],
        dependencies: [
          .target(name: "\(name)Feature")
        ]
      )
    ]

    if hasTests {
      targets.append(
        .target(
          name: "\(name)FeatureTests",
          destinations: Environment.destinations,
          product: .unitTests,
          bundleId: Environment.bundleId(for: "\(name)FeatureTests"),
          deploymentTargets: Environment.deploymentTarget,
          sources: ["Tests/**"],
          dependencies: [
            .target(name: "\(name)Feature")
          ]
        )
      )
        var schemes: [Scheme] = [
            // Scheme for Feature Framework
            Environment.makeScheme(
                name: "\(name)Feature",
                targets: hasTests ? ["\(name)Feature", "\(name)FeatureTests"] : ["\(name)Feature"]
            ),
            // Scheme for Demo App
            Environment.makeDemoScheme(
                name: "\(name)FeatureDemo",
            )
                executableTarget: "\(name)FeatureDemo"
        ]

        return Project(name: "\(name)Feature", targets: targets, schemes: schemes)
        if hasTests {
            targets.append(
                .target(
                    name: "\(name)FeatureTests",
                    product: .unitTests,
                    destinations: Environment.destinations,
                    bundleId: Environment.bundleId(for: "\(name)FeatureTests"),
                    sources: ["Tests/**"],
                    deploymentTargets: Environment.deploymentTarget,
                    dependencies: [
                        .target(name: "\(name)Feature")
                    ]
                )
            )
        }

    }

    return Project(name: "\(name)Feature", targets: targets)
  }
}
