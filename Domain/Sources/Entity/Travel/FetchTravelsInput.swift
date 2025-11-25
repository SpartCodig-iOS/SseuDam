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

    public init(limit: Int, page: Int) {
        self.limit = limit
        self.page = page
    }
}
