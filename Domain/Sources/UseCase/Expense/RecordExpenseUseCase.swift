//
//  RecordExpenseUseCase.swift
//  Domain
//
//  Created by 홍석현 on 11/17/25.
//

import Foundation

public protocol RecordExpenseUseCaseProtocol {
    func execute(input: RecordExpenseInput) async throws
}

public struct RecordExpenseUseCase: RecordExpenseUseCaseProtocol {
    public func execute(input: RecordExpenseInput) async throws {
        return
    }
}
