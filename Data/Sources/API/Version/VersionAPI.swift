//
//  VersionAPI.swift
//  Data
//
//  Created by Wonji Suh  on 12/8/25.
//

import Foundation

public enum VersionAPI {
    case getVersion

    var description: String {
        switch self {
            case .getVersion:
                return ""
        }
    }
}
