//
//  ExpenseRepositoryProtocol.swift
//  Domain
//
//  Created by 홍석현 on 11/21/25.
//

import Foundation

public protocol ExpenseRepositoryProtocol {
    // 지출 내역 저장
    func save(expense: Expense) async throws
    
    // 지출 내역 수정
    func update(expense: Expense) async throws
    
}
