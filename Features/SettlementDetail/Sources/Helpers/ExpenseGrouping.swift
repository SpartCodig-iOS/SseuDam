//
//  ExpenseGrouping.swift
//  SettlementDetailFeature
//
//  Created by SseuDam on 2025.
//

import Foundation
import Domain

struct ExpensesByDate: Identifiable {
    let id = UUID()
    let date: Date
    let expenses: [ExpenseDetail]
}

extension Array where Element == ExpenseDetail {
    func groupedByDate() -> [ExpensesByDate] {
        let calendar = Calendar.current

        // 날짜별로 그룹핑
        let grouped = Dictionary(grouping: self) { expense in
            calendar.startOfDay(for: expense.expenseDate)
        }

        // 날짜 오름차순으로 정렬, 같은 날짜 내에서는 금액 높은 순
        return grouped
            .sorted { $0.key < $1.key }
            .map { dateKey, expenses in
                let sortedExpenses = expenses.sorted { $0.shareAmount > $1.shareAmount }
                return ExpensesByDate(date: dateKey, expenses: sortedExpenses)
            }
    }
}
