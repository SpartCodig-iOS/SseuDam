//
//  CreateExpenseRequestDTO.swift
//  Data
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import Domain

public struct CreateExpenseRequestDTO: Encodable {
    let title: String
    let amount: Double
    let currency: String
    let expenseDate: String
    let payerId: String
    let category: String
    let participantIds: [String]
}
