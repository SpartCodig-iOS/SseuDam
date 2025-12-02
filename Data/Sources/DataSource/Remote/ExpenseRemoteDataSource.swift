//
//  ExpenseRemoteDataSource.swift
//  Data
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import Domain
import Moya
import NetworkService

public protocol ExpenseRemoteDataSourceProtocol {
    func fetchTravelExpenses(travelId: String, page: Int, limit: Int) async throws -> TravelExpenseResponseDTO
    func createExpense(travelId: String, body: CreateExpenseRequestDTO) async throws
    func updateExpense(travelId: String, expenseId: String, body: UpdateExpenseRequestDTO) async throws
    func deleteExpense(travelId: String, expenseId: String) async throws
}

public struct ExpenseRemoteDataSource: ExpenseRemoteDataSourceProtocol {

    private let provider: MoyaProvider<ExpenseAPI>

    public init(provider: MoyaProvider<ExpenseAPI> = MoyaProvider<ExpenseAPI>()) {
        self.provider = provider
    }

    public func fetchTravelExpenses(
        travelId: String,
        page: Int,
        limit: Int
    ) async throws -> TravelExpenseResponseDTO {
        let response: BaseResponse<TravelExpenseResponseDTO> =
        try await provider.request(.fetchTravelExpenses(travelId: travelId, page: page, limit: limit))

        guard let data = response.data else {
            throw NetworkError.noData
        }

        return data
    }

    public func createExpense(travelId: String, body: CreateExpenseRequestDTO) async throws {
        let _: BaseResponse<EmptyDTO> = try await provider.request(.createExpense(travelId: travelId, body: body))
    }

    public func updateExpense(travelId: String, expenseId: String, body: UpdateExpenseRequestDTO) async throws {
        let _: BaseResponse<EmptyDTO> = try await provider.request(.updateExpense(travelId: travelId, expenseId: expenseId, body: body))
    }

    public func deleteExpense(travelId: String, expenseId: String) async throws {
        let _: BaseResponse<EmptyDTO> = try await provider.request(.deleteExpense(travelId: travelId, expenseId: expenseId))
    }
}

// MARK: - ExpenseAPI
public enum ExpenseAPI {
    case fetchTravelExpenses(travelId: String, page: Int, limit: Int)
    case createExpense(travelId: String, body: CreateExpenseRequestDTO)
    case updateExpense(travelId: String, expenseId: String, body: UpdateExpenseRequestDTO)
    case deleteExpense(travelId: String, expenseId: String)
}

extension ExpenseAPI: BaseTargetType {

    public typealias Domain = SseuDamDomain

    public var domain: SseuDamDomain {
        return .travels
    }

    public var urlPath: String {
        switch self {
        case .fetchTravelExpenses(let travelId, _, _):
            return "/\(travelId)/expenses"
        case .createExpense(let travelId, _):
            return "/\(travelId)/expenses"
        case .updateExpense(let travelId, let expenseId, let _):
            return "/\(travelId)/expenses/\(expenseId)"
        case .deleteExpense(let travelId, let expenseId):
            return "/\(travelId)/expenses/\(expenseId)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .fetchTravelExpenses: return .get
        case .createExpense: return .post
        case .updateExpense: return .patch
        case .deleteExpense: return .delete
        }
    }

    public var parameters: [String: Any]? {
        switch self {
        case .fetchTravelExpenses(_, let page, let limit):
            return [
                "page": page,
                "limit": limit
            ]
        case .createExpense(_, let body):
            return body.toDictionary
        case .updateExpense(_, _, let body):
            return body.toDictionary
        case .deleteExpense(_, _):
            return nil
        }
    }

    public var error: [Int : NetworkError]? { nil }
}
