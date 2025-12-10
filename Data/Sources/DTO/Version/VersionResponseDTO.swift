//
//  VersionResponseDTO.swift
//  Data
//
//  Created by Wonji Suh  on 12/8/25.
//

import Foundation

public struct VersionResponseDTO: Decodable {
    let bundleID, latestVersion: String
    let releaseNotes, trackName, minimumOSVersion, lastUpdated: String?
    let forceUpdate: Bool?
    let currentVersion: String?
    let shouldUpdate: Bool
    let message: String?
    let appStoreURL: String

    enum CodingKeys: String, CodingKey {
        case bundleID = "bundleId"
        case latestVersion, releaseNotes, trackName
        case minimumOSVersion = "minimumOsVersion"
        case lastUpdated, forceUpdate, currentVersion, shouldUpdate
        case message = "message"
        case appStoreURL = "appStoreUrl"
    }
}
