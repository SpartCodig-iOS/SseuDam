import ProjectDescription

// MARK: - Module Dependencies Extension
public extension TargetDependency {
    enum Features {}
}

public extension TargetDependency {
    // MARK: - Core Modules
    static let Domain: TargetDependency = .project(target: "Domain", path: .relativeToRoot("Domain"))
    static let Data: TargetDependency = .project(target: "Data", path: .relativeToRoot("Data"))
    static let DesignSystem: TargetDependency = .project(target: "DesignSystem", path: .relativeToRoot("DesignSystem"))
    static let NetworkService: TargetDependency = .project(target: "NetworkService", path: .relativeToRoot("NetworkService"))
}

public extension TargetDependency.Features {
    // MARK: - Feature Modules
    static let Login: TargetDependency = .project(target: "LoginFeature", path: .relativeToRoot("Features/Login"))
    static let Main: TargetDependency = .project(target: "MainFeature", path: .relativeToRoot("Features/Main"))
}

// MARK: - Feature Names
public enum FeatureName: String {
    case Login
    case Main

    public var targetName: String {
        return "\(rawValue)Feature"
    }
}
