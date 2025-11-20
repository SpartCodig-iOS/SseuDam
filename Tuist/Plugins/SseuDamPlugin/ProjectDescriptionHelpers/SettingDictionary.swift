//
//  SettingDictionary.swift
//  SseuDamPlugin
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import ProjectDescription

public extension SettingsDictionary {
  // Tuist 기본 제공이 아닌, 커스텀 혹은 래핑이 필요한 항목들만 최소한으로 유지

  func setProductName(_ value: String) -> SettingsDictionary {
    merging(["PRODUCT_NAME": SettingValue(stringLiteral: value)]) { _, new in new }
  }

  func setMarketingVersion(_ value: String) -> SettingsDictionary {
    merging(["MARKETING_VERSION": SettingValue(stringLiteral: value)]) { _, new in new }
  }

  func setCurrentProjectVersion(_ value: String) -> SettingsDictionary {
    merging(["CURRENT_PROJECT_VERSION": SettingValue(stringLiteral: value)]) { _, new in new }
  }

  func setCodeSignIdentity(_ value: String = "iPhone Developer") -> SettingsDictionary {
    merging(["CODE_SIGN_IDENTITY": SettingValue(stringLiteral: value)]) { _, new in new }
  }

  func setCodeSignStyle(_ value: String = "Manual") -> SettingsDictionary {
    merging(["CODE_SIGN_STYLE": SettingValue(stringLiteral: value)]) { _, new in new }
  }

  func setSwiftVersion(_ value: String) -> SettingsDictionary {
    merging(["SWIFT_VERSION": SettingValue(stringLiteral: value)]) { _, new in new }
  }

  func setVersioningSystem(_ value: String = "apple-generic") -> SettingsDictionary {
    merging(["VERSIONING_SYSTEM": SettingValue(stringLiteral: value)]) { _, new in new }
  }

  func setDevelopmentTeam(_ value: String) -> SettingsDictionary {
    merging(["DEVELOPMENT_TEAM": SettingValue(stringLiteral: value)]) { _, new in new }
  }

  func setCFBundleDisplayName(_ value: String) -> SettingsDictionary {
    merging(["CFBundleDisplayName": SettingValue(stringLiteral: value)]) { _, new in new }
  }

  func setASAuthenticationServicesEnabled(_ value: String = "YES") -> SettingsDictionary {
    merging(["AS_AUTHENTICATION_SERVICES_ENABLED": SettingValue(stringLiteral: value)]) { _, new in new }
  }

  func setProvisioningProfileSpecifier(_ value: String) -> SettingsDictionary {
    merging(["PROVISIONING_PROFILE_SPECIFIER": SettingValue(stringLiteral: value)]) { _, new in new }
  }

  func setCFBundleDevelopmentRegion(_ value: String = "ko") -> SettingsDictionary {
    merging(["CFBundleDevelopmentRegion": SettingValue(stringLiteral: value)]) { _, new in new }
  }
}
