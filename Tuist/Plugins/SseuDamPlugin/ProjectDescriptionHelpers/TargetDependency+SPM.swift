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
  static let Supabase : TargetDependency = .external(name: "Supabase")
  static let GoogleSignIn: TargetDependency = .external(name: "GoogleSignIn")
  static let LogMacro: TargetDependency = .external(name: "LogMacro")
}

