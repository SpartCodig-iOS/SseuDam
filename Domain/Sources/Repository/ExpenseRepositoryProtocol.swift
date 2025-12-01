//
//  ExpenseRepositoryProtocol.swift
//  Domain
//
//  Created by 홍석현 on 11/21/25.
//

import Foundation

public protocol ExpenseRepositoryProtocol {
    // 여행의 지출 내역 조회
    func fetchTravelExpenses(travelId: String, page: Int, limit: Int) async throws -> [Expense]

    // 지출 내역 저장
    func save(travelId: String, expense: Expense) async throws

    // 지출 내역 수정
    func update(travelId: String, expense: Expense) async throws
}
