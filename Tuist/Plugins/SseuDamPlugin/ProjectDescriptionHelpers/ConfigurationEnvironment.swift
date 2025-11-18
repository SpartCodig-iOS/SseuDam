//
//  ConfigurationEnvironment.swift
//  SseuDamPlugin
//
//  Created by Wonji Suh  on 11/17/25.
//

public enum ConfigurationEnvironment: CaseIterable {
    case dev

    public var name: String {
        switch self {
        case .dev: "Dev"
        }
    }
}
