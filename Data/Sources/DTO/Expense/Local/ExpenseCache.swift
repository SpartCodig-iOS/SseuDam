//
//  ExpenseCache.swift
//  Data
//
//  Created by 홍석현 on 12/9/25.
//

import Foundation

public struct ExpenseCache: Codable {
    let travelId: String
    let expenses: [TravelExpenseResponseDTO.ExpenseDTO]
    let cachedAt: Date
    let expiredAt: Date
    
    var isExpired: Bool {
        Date() > expiredAt
    }
    
    init(
        travelId: String,
        expenses: [TravelExpenseResponseDTO.ExpenseDTO],
    ) {
        self.travelId = travelId
        self.expenses = expenses
        self.cachedAt = .now
        self.expiredAt = .now.addingTimeInterval(3600)
    }
}
 
