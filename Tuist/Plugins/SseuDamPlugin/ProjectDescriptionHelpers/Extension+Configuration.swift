//
//  Extension+Configuration.swift
//  SseuDamPlugin
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import ProjectDescription

extension ConfigurationName {
    static let dev = ConfigurationName.configuration(ConfigurationEnvironment.dev.name)
}

public extension Array where Element == Configuration {
    static let `default`: [Configuration] = [
        .debug(name: .dev, xcconfig: .path(.dev)),
        .release(name: .release, xcconfig: .path(.release))
    ]
}

public extension ProjectDescription.Path {
    static func path(_ configuration: ConfigurationName) -> Self {
        return .relativeToRoot("Config/\(configuration.rawValue).xcconfig")
    }
}
