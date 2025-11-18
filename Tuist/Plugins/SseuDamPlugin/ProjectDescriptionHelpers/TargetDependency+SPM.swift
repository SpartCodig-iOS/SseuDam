import ProjectDescription

// MARK: - SPM Dependencies Extension
public extension TargetDependency {
    enum SPM {}
}

public extension TargetDependency.SPM {
    // MARK: - Architecture
    static let ComposableArchitecture: TargetDependency = .external(name: "ComposableArchitecture")
    static let TCACoordinators: TargetDependency = .external(name: "TCACoordinators")

    // MARK: - Networking
    static let Moya: TargetDependency = .external(name: "Moya")
    static let LogMacro: TargetDependency = .external(name: "LogMacro")
}

