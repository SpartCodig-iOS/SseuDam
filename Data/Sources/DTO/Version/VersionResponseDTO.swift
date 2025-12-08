//
//  VersionResponseDTO.swift
//  Data
//
//  Created by Wonji Suh  on 12/8/25.
//

import Foundation

public struct VersionResponseDTO: Decodable {
    let bundleID, latestVersion, releaseNotes, trackName: String
    let minimumOSVersion: String
    let lastUpdated: String
    let forceUpdate: Bool
    let currentVersion: String
    let shouldUpdate: Bool
    let message: String
    let appStoreURL: String

    enum CodingKeys: String, CodingKey {
        case bundleID = "bundleId"
        case latestVersion, releaseNotes, trackName
        case minimumOSVersion = "minimumOsVersion"
        case lastUpdated, forceUpdate, currentVersion, shouldUpdate, message
        case appStoreURL = "appStoreUrl"
    }
}
