//
//  DeeplinkDestination.swift
//  Domain
//
//  Created by Wonji Suh on 12/12/25.
//

import Foundation

public enum DeeplinkDestination: Equatable, Sendable {
    case travel(TravelDeeplink)
    case invite(code: String)
    case unknown(url: String)
}

public enum TravelDeeplink: Equatable, Sendable {
    case detail(travelId: String)
    case settings(travelId: String)
    case expense(travelId: String, expenseId: String)
    case settlement(travelId: String)
}

public enum DeeplinkResult: Equatable, Sendable {
    case success(DeeplinkDestination)
    case requiresLogin(destination: DeeplinkDestination)
    case invalid(url: String, reason: String)
}
