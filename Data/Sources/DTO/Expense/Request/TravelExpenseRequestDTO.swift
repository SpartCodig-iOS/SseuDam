//
//  TravelExpenseRequestDTO.swift
//  Data
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation

struct TravelExpenseRequestDTO: Encodable {
    private let travelId: String
    private let limit: Int
    private let page: Int
    
    init(travelId: String, limit: Int, page: Int) {
        self.travelId = travelId
        self.limit = limit
        self.page = page
    }
}
