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
    static let CombineMoya: TargetDependency = .external(name: "CombineMoya")
}

// MARK: - Usage Example
/*
 사용 예시:

 let project = Project.makeFramework(
     name: "NetworkService",
     dependencies: [
         .SPM.Moya,
         .SPM.CombineMoya
     ]
 )

 let project = Project.makeFeature(
     name: .MyFeature,
     dependencies: [
         .SPM.ComposableArchitecture,
         .SPM.TCACoordinators,
         .Domain
     ]
 )
*/
