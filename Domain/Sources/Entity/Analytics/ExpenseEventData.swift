import Foundation

/// Expense 이벤트 데이터
public struct ExpenseEventData: Sendable {
    public let travelId: String
    public let expenseId: String?
    public let amount: Double?
    public let currency: String?
    public let category: String?
    public let payerId: String?
    public let source: String?
    public let tab: String?
    public let expenseDate: String?
    public let errorCode: String?

    public init(
        travelId: String,
        expenseId: String? = nil,
        amount: Double? = nil,
        currency: String? = nil,
        category: String? = nil,
        payerId: String? = nil,
        source: String? = nil,
        tab: String? = nil,
        expenseDate: String? = nil,
        errorCode: String? = nil
    ) {
        self.travelId = travelId
        self.expenseId = expenseId
        self.amount = amount
        self.currency = currency
        self.category = category
        self.payerId = payerId
        self.source = source
        self.tab = tab
        self.expenseDate = expenseDate
        self.errorCode = errorCode
    }
}

/// Expense 이벤트 타입
public enum ExpenseEventType: String, Sendable {
    case view = "expense_view"
    case openDetail = "expense_open_detail"
    case createSuccess = "expense_create_success"
    case createFailure = "expense_create_failure"
    case update = "expense_update"
    case delete = "expense_delete"
}