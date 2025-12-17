//
//  ExpenseChartView.swift
//  ExpenseListFeature
//
//  Created by 홍석현 on 12/11/25.
//

import SwiftUI
import Domain
import DesignSystem
import Charts

struct ExpenseChartView: View {
    private let expense: [Expense]
    private let startDate: Date
    private let endDate: Date
    @Binding var selectedDateRange: ClosedRange<Date>?
    @Binding var currentPage: Int

    private let barWidth: CGFloat = 18

    private static let mmddFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MM.dd"
        return formatter
    }()

    private var allDayStrings: [String] {
        guard let start = Expense.parseDate(Expense.formatDate(startDate)),
              let end = Expense.parseDate(Expense.formatDate(endDate)) else {
            return []
        }

        var dateStrings: [String] = []
        var current = start
        let calendar = Calendar(identifier: .gregorian)

        while current <= end {
            dateStrings.append(Expense.formatDate(current))
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }

        return dateStrings
    }
    
    private var dayChunks: [[String]] {
        let days = allDayStrings
        return stride(from: 0, to: days.count, by: 7).map {
            Array(days[$0..<min($0 + 7, days.count)])
        }
    }

    private var dailyExpenseMap: [String: Double] {
        expense.reduce(into: [:]) { map, exp in
            map[exp.formatExpenseDate(), default: 0] += exp.convertedAmount
        }
    }

    init(
        expense: [Expense],
        startDate: Date,
        endDate: Date,
        selectedDateRange: Binding<ClosedRange<Date>?>,
        currentPage: Binding<Int>
    ) {
        self.expense = expense
        self.startDate = startDate
        self.endDate = endDate
        self._selectedDateRange = selectedDateRange
        self._currentPage = currentPage
    }

    var body: some View {
        VStack {
            if dayChunks.isEmpty {
                ContentUnavailableView("기간이 설정되지 않았습니다.", systemImage: "calendar")
            } else {
                TabView(selection: $currentPage) {
                    ForEach(Array(dayChunks.enumerated()), id: \.offset) { index, chunk in
                        chartView(for: chunk)
                            .tag(index)
                            .padding(.bottom, 16)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .overlay(alignment: .bottom) {
                    if dayChunks.count > 1 {
                        HStack(spacing: 8) {
                            ForEach(0..<dayChunks.count, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? Color.black : Color.gray)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }
            }
        }
        .frame(height: 126)
        .onChange(of: selectedDateString) { _, newValue in
            guard let dateStr = newValue,
                  let date = Expense.parseDate(dateStr) else { return }

            // 탭한 날짜만 선택 (단일 날짜 범위)
            let calendar = Calendar.current
            let selected = calendar.startOfDay(for: date)
            selectedDateRange = selected...selected
        }
    }
    
    private func chartView(for chunk: [String]) -> some View {
        Chart {
            ForEach(chunk, id: \.self) { dateString in
                let total = dailyExpenseMap[dateString] ?? 0
                BarMark(
                    x: .value("Day", dateString),
                    y: .value("Total", total),
                    width: MarkDimension(floatLiteral: barWidth)
                )
                .foregroundStyle(barColor(for: dateString))
                .cornerRadius(barWidth / 2)
            }
        }
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                if let dateStr = value.as(String.self),
                   let date = Expense.parseDate(dateStr) {
                    AxisValueLabel(centered: true) {
                        Text(Self.mmddFormatter.string(from: date))
                            .font(.app(.caption2, weight: .medium))
                            .foregroundStyle(Color.black)
                    }
                }
            }
        }
        .chartGesture { proxy in
            SpatialTapGesture()
                .onEnded { value in
                    // 정확한 타입 추론을 위해 as: String.self 명시
                    if let dateString = proxy.value(atX: value.location.x, as: String.self) {
                        selectedDateString = dateString
                    }
                }
        }
        .frame(height: 94)
    }

    @State private var selectedDateString: String?

    private func barColor(for dateString: String) -> Color {
        guard let date = Expense.parseDate(dateString) else { return .primary100 }

        // 선택된 범위가 있으면 범위 체크
        if let range = selectedDateRange {
            let calendar = Calendar.current
            let dateDay = calendar.startOfDay(for: date)
            let rangeStart = calendar.startOfDay(for: range.lowerBound)
            let rangeEnd = calendar.startOfDay(for: range.upperBound)

            return (dateDay >= rangeStart && dateDay <= rangeEnd) ? .primary500 : .primary100
        }

        // 선택된 범위가 없으면 기본 색상
        return .primary100
    }
}

// MARK: - Previews

#Preview("기본 - 여러 날짜") {
    @Previewable @State var selectedDateRange: ClosedRange<Date>? = nil
    let calendar = Calendar.current

    let startDate = calendar.date(byAdding: .day, value: -2, to: Date())!
    let endDate = Date()

    let expenses = [
        Expense.mock1.withDate(calendar.date(byAdding: .day, value: -2, to: Date())!),
        Expense.mock2.withDate(calendar.date(byAdding: .day, value: -1, to: Date())!),
        Expense.mock3.withDate(Date())
    ]

    ExpenseChartView(
        expense: expenses,
        startDate: startDate,
        endDate: endDate,
        selectedDateRange: $selectedDateRange,
        currentPage: .constant(0)
    )
    .padding()
}

#Preview("2일 여행") {
    @Previewable @State var selectedDateRange: ClosedRange<Date>? = nil
    let calendar = Calendar.current

    let startDate = calendar.date(byAdding: .day, value: -5, to: Date())!
    let endDate = calendar.date(byAdding: .day, value: -1, to: Date())!

    let expenses = [
        Expense.mock1.withDate(startDate),
        Expense.mock2.withDate(endDate)
    ]

    ExpenseChartView(
        expense: expenses,
        startDate: startDate,
        endDate: endDate,
        selectedDateRange: $selectedDateRange,
        currentPage: .constant(0)
    )
    .padding()
}

#Preview("긴 여행 - 화면 벗어남") {
    @Previewable @State var selectedDateRange: ClosedRange<Date>? = nil
    let calendar = Calendar.current

    let startDate = calendar.date(byAdding: .day, value: -13, to: Date())!
    let endDate = Date()

    let expenses = [
        Expense.mock1.withDate(calendar.date(byAdding: .day, value: -13, to: Date())!),
        Expense.mock2.withDate(calendar.date(byAdding: .day, value: -11, to: Date())!),
        Expense.mock3.withDate(calendar.date(byAdding: .day, value: -9, to: Date())!),
        Expense.mock4.withDate(calendar.date(byAdding: .day, value: -7, to: Date())!),
        Expense.mock5.withDate(calendar.date(byAdding: .day, value: -4, to: Date())!),
        Expense.mock6.withDate(Date())
    ]

    ExpenseChartView(
        expense: expenses,
        startDate: startDate,
        endDate: endDate,
        selectedDateRange: $selectedDateRange,
        currentPage: .constant(0)
    )
    .padding()
}

#Preview("빈 데이터 - 지출 없음") {
    @Previewable @State var selectedDateRange: ClosedRange<Date>? = nil
    let calendar = Calendar.current

    let startDate = calendar.date(byAdding: .day, value: -4, to: Date())!
    let endDate = Date()

    ExpenseChartView(
        expense: [],
        startDate: startDate,
        endDate: endDate,
        selectedDateRange: $selectedDateRange,
        currentPage: .constant(0)
    )
    .padding()
}

#Preview("일부 날짜만 지출") {
    @Previewable @State var selectedDateRange: ClosedRange<Date>? = nil
    let calendar = Calendar.current

    let startDate = calendar.date(byAdding: .day, value: -6, to: Date())!
    let endDate = Date()

    let expenses = [
        Expense.mock1.withDate(calendar.date(byAdding: .day, value: -6, to: Date())!),
        Expense.mock2.withDate(calendar.date(byAdding: .day, value: -3, to: Date())!),
        Expense.mock3.withDate(Date())
    ]

    ExpenseChartView(
        expense: expenses,
        startDate: startDate,
        endDate: endDate,
        selectedDateRange: $selectedDateRange,
        currentPage: .constant(0)
    )
    .padding()
}

// MARK: - Helper Extension
extension Expense {
    fileprivate func withDate(_ date: Date) -> Expense {
        Expense(
            id: id,
            title: title,
            amount: amount,
            currency: currency,
            convertedAmount: convertedAmount,
            expenseDate: date,
            category: category,
            payer: payer,
            participants: participants
        )
    }
}
