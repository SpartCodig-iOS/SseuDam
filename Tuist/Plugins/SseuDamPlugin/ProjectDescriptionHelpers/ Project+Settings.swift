//
//   Project+Settings.swift
//  SseuDamPlugin
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import ProjectDescription

extension Settings {
  private static func commonSettings(
    appName: String,
    displayName: String,
    provisioningProfile: String,
    setSkipInstall: Bool
  ) -> SettingsDictionary {
    return SettingsDictionary()
      .setProductName(appName)
      .setCFBundleDisplayName(displayName)
      .setDebugInformationFormat("dwarf-with-dsym")
      .setProvisioningProfileSpecifier(provisioningProfile)
      .setSkipInstall(setSkipInstall)
      .setCFBundleDevelopmentRegion("ko")
  }

  public static let appMainSetting: Settings = .settings(
    base: SettingsDictionary()
      .setProductName(Environment.appName)
      .setCFBundleDisplayName(Environment.appName)
      .setMarketingVersion("1.0.0")
      .setASAuthenticationServicesEnabled()
      .setCurrentProjectVersion("10")
      .setCodeSignIdentity()
      .setCodeSignStyle()
      .setSwiftVersion("6.0")
      .setVersioningSystem()
      .setProvisioningProfileSpecifier("match Development \(Environment.organizationName)")
      .setDevelopmentTeam(Environment.organizationTeamId)
      .setCFBundleDevelopmentRegion()
      .setDebugInformationFormat(),
    configurations: [
      .debug(
        name: .debug,
        settings:
          commonSettings(
            appName: Environment.appName,
            displayName: Environment.appName,
            provisioningProfile: "match Development \(Environment.organizationName)",
            setSkipInstall: false
          ),
        xcconfig: .path(.dev)
      ),
      .release(
        name: .release,
        settings:
          commonSettings(
            appName: Environment.appName,
            displayName: Environment.appName,
            provisioningProfile: "match AppStore \(Environment.organizationName)",
            setSkipInstall: false
          ),
        xcconfig: .path(.release)
      ),
    ], defaultSettings: .recommended
  )

}
