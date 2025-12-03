//
//  TravelTab.swift
//  TravelFeature
//
//  Created by 김민희 on 11/25/25.
//

import Foundation
import Domain

public enum TravelTab: String, CaseIterable, Equatable, Hashable {
    case ongoing = "진행중"
    case completed = "완료됨"
}

extension TravelTab {
    var status: TravelStatus {
        switch self {
        case .ongoing:
            return .active
        case .completed:
            return .archived
        }
    }
}
