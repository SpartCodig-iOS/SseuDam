//
//  KeychainManagerDependency.swift
//  Domain
//
//  Created by Wonji Suh on 02/09/26.
//

import Foundation
import ComposableArchitecture

// MARK: - Dependency Key
public struct KeychainManagerDependency: DependencyKey {
  public static var liveValue: KeychainManaging {
    KeychainManager.live
  }

  public static var testValue: KeychainManaging {
    InMemoryKeychainManager()
  }

  public static var previewValue: KeychainManaging = testValue
}

// MARK: - Dependency Values Extension
public extension DependencyValues {
  var keychainManager: KeychainManaging {
    get { self[KeychainManagerDependency.self] }
    set { self[KeychainManagerDependency.self] = newValue }
  }
}