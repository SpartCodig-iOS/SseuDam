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
    static let Alamofire: TargetDependency = .external(name: "Alamofire")
}

// MARK: - Usage Example
/*
 사용 예시:

 let project = Project.makeFramework(
     name: "NetworkService",
     dependencies: [
         .SPM.Alamofire
     ]
 )

 let project = Project.makeFramework(
     name: "MyFeature",
     dependencies: [
         .SPM.ComposableArchitecture,
         .SPM.TCACoordinators,
         .project(target: "Domain", path: "../Domain")
     ]
 )
*/
