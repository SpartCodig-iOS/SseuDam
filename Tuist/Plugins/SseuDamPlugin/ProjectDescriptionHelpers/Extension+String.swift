//
//  Extension+String.swift
//  SseuDamPlugin
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import ProjectDescription

extension String {
  public static func appVersion(version: String = "1.0.0") -> String {
    return version
  }

  public static func mainBundleID() -> String {
    return Environment.organizationName
  }

  public static func appBuildVersion(buildVersion: String = "10") -> String {
    return buildVersion
  }
}
