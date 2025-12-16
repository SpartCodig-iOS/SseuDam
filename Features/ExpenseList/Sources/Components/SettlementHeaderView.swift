//
//  SettlementHeaderView.swift
//  ExpenseListFeature
//
//  Created by 홍석현 on 11/28/25.
//

import SwiftUI
import DesignSystem
import Domain

public struct SettlementHeaderView: View {
    let totalAmount: String
    let startDate: Date
    let endDate: Date
    let myExpenseAmount: String
    let expenses: [Expense]
    @Binding var selectedDateRange: ClosedRange<Date>?
    @Binding var currentPage: Int

    @State private var showDatePicker = false

    public init(
        totalAmount: String,
        startDate: Date,
        endDate: Date,
        myExpenseAmount: String,
        expenses: [Expense],
        selectedDateRange: Binding<ClosedRange<Date>?>,
        currentPage: Binding<Int>
    ) {
        self.totalAmount = totalAmount
        self.startDate = startDate
        self.endDate = endDate
        self.myExpenseAmount = myExpenseAmount
        self.expenses = expenses
        self._selectedDateRange = selectedDateRange
        self._currentPage = currentPage
    }

    public var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                // 날짜 선택 버튼
                Button {
                    showDatePicker = true
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedDateLabel)
                            .font(.app(.body, weight: .medium))
                            .foregroundStyle(Color.gray7)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundStyle(Color.gray5)
                    }
                }
                .sheet(isPresented: $showDatePicker) {
                    DateRangePicker(
                        startDate: startDate,
                        endDate: endDate,
                        selectedRange: $selectedDateRange
                    )
                }


                // 총 지출 금액
                Text("₩\(totalAmount)")
                    .font(.app(.title1, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
            }
            .padding(.vertical, 12)

            // 차트
            ExpenseChartView(
                expense: expenses,
                startDate: startDate,
                endDate: endDate,
                selectedDateRange: $selectedDateRange,
                currentPage: $currentPage
            )
            .padding(.horizontal, 20)
        }
    }

    private var selectedDateLabel: String {
        if let range = selectedDateRange {
            let calendar = Calendar.current
            // 단일 날짜인지 확인 (시작과 끝이 같은 날)
            if calendar.isDate(range.lowerBound, inSameDayAs: range.upperBound) {
                // 단일 날짜: "yyyy.MM.dd"
                return dateFormatter.string(from: range.lowerBound)
            } else {
                // 날짜 범위: "yyyy.MM.dd ~ yyyy.MM.dd"
                return "\(dateFormatter.string(from: range.lowerBound)) ~ \(dateFormatter.string(from: range.upperBound))"
            }
        } else {
            // 전체 선택된 경우: "yyyy.MM.dd ~ yyyy.MM.dd"
            return "\(dateFormatter.string(from: startDate)) ~ \(dateFormatter.string(from: endDate))"
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }
}

#Preview {
    SettlementHeaderView(
        totalAmount: "255,450",
        startDate: Date().addingTimeInterval(-86400 * 2),
        endDate: Date(),
        myExpenseAmount: "255,450",
        expenses: [Expense.mock1, Expense.mock2, Expense.mock3],
        selectedDateRange: .constant(nil),
        currentPage: .constant(0)
    )
}
