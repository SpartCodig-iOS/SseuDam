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
    static let Expense: TargetDependency = .project(target: "ExpenseFeature", path: .relativeToRoot("Features/Expense"))
    static let ExpenseList: TargetDependency = .project(target: "ExpenseListFeature", path: .relativeToRoot("Features/ExpenseList"))
    static let Login: TargetDependency = .project(target: "LoginFeature", path: .relativeToRoot("Features/Login"))
    static let Main: TargetDependency = .project(target: "MainFeature", path: .relativeToRoot("Features/Main"))
    static let Member: TargetDependency = .project(target: "MemberFeature", path: .relativeToRoot("Features/Member"))
    static let OnBoarding: TargetDependency = .project(target: "OnBoardingFeature", path: .relativeToRoot("Features/OnBoarding"))
    static let Profile: TargetDependency = .project(target: "ProfileFeature", path: .relativeToRoot("Features/Profile"))
    static let SaveExpense: TargetDependency = .project(target: "SaveExpenseFeature", path: .relativeToRoot("Features/SaveExpense"))
    static let Settlement: TargetDependency = .project(target: "SettlementFeature", path: .relativeToRoot("Features/Settlement"))
    static let SettlementDetail: TargetDependency = .project(target: "SettlementDetailFeature", path: .relativeToRoot("Features/SettlementDetail"))
    static let SettlementResult: TargetDependency = .project(target: "SettlementResultFeature", path: .relativeToRoot("Features/SettlementResult"))
    static let Splash: TargetDependency = .project(target: "SplashFeature", path: .relativeToRoot("Features/Splash"))
    static let Travel: TargetDependency = .project(target: "TravelFeature", path: .relativeToRoot("Features/Travel"))
    static let Web: TargetDependency = .project(target: "WebFeature", path: .relativeToRoot("Features/Web"))
}

// MARK: - Feature Names
public enum FeatureName: String {
    case Expense
    case ExpenseList
    case Login
    case Main
    case Member
    case OnBoarding
    case Profile
    case SaveExpense
    case Settlement
    case SettlementDetail
    case SettlementResult
    case Splash
    case Travel
    case Web

    public var targetName: String {
        return "\(rawValue)Feature"
    }
}
