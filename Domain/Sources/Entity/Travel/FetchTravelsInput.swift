//
//  FetchTravelsInput.swift
//  Domain
//
//  Created by 김민희 on 11/19/25.
//

import Foundation

public struct FetchTravelsInput {
    public let limit: Int
    public let page: Int
    public let status: TravelStatus?

    public init(
        limit: Int = 20,
        page: Int,
        status: TravelStatus
    ) {
        self.limit = limit
        self.page = page
        self.status = status
    }
}
