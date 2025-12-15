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

    private let barWidth: CGFloat = 18
    @State private var dragStartDateString: String?

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

    private var dailyExpenseMap: [String: Double] {
        expense.reduce(into: [:]) { map, exp in
            map[exp.formatExpenseDate(), default: 0] += exp.convertedAmount
        }
    }

    private var chartData: [(dateString: String, total: Double)] {
        allDayStrings.map { ($0, dailyExpenseMap[$0] ?? 0) }
    }

    init(
        expense: [Expense],
        startDate: Date,
        endDate: Date,
        selectedDateRange: Binding<ClosedRange<Date>?>
    ) {
        self.expense = expense
        self.startDate = startDate
        self.endDate = endDate
        self._selectedDateRange = selectedDateRange
    }

    var body: some View {
        Chart {
            ForEach(Array(chartData.enumerated()), id: \.offset) { _, item in
                BarMark(
                    x: .value("Day", item.dateString),
                    y: .value("Total", item.total),
                    width: MarkDimension(floatLiteral: barWidth)
                )
                .foregroundStyle(barColor(for: item.dateString))
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
        .chartXSelection(value: currentSelectionBinding)
        .chartGesture { proxy in
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    handleDragChange(value: value, proxy: proxy)
                }
                .onEnded { value in
                    handleDragEnd(value: value, proxy: proxy)
                }
        }
        .padding(.horizontal, 4)
        .frame(height: 120)
    }

    // 현재 선택 중인 날짜 (드래그 중일 수도 있음)
    private var currentSelectionBinding: Binding<String?> {
        Binding(
            get: {
                if let dragStart = dragStartDateString {
                    return dragStart
                }
                if let range = selectedDateRange {
                    return Expense.formatDate(range.lowerBound)
                }
                return nil
            },
            set: { _ in }
        )
    }

    private func handleDragChange(value: DragGesture.Value, proxy: ChartProxy) {
        let location = value.location
        if let dateStr: String = proxy.value(atX: location.x, as: String.self) {
            if dragStartDateString == nil {
                // 드래그 시작
                dragStartDateString = dateStr
            } else {
                // 드래그 중 - 범위 업데이트
                updateRangeSelection(from: dragStartDateString!, to: dateStr)
            }
        }
    }

    private func handleDragEnd(value: DragGesture.Value, proxy: ChartProxy) {
        let location = value.location
        if let endDateStr: String = proxy.value(atX: location.x, as: String.self),
           let startDateStr = dragStartDateString {

            let dragDistance = value.translation.width

            // 드래그가 거의 없었으면 단일 선택 (탭)
            if abs(dragDistance) < 10 {
                // 단일 날짜 선택
                if let date = Expense.parseDate(startDateStr) {
                    selectedDateRange = date...date
                }
            } else {
                // 범위 선택
                updateRangeSelection(from: startDateStr, to: endDateStr)
            }
        }
        // 드래그 상태 초기화
        dragStartDateString = nil
    }

    private func updateRangeSelection(from startStr: String, to endStr: String) {
        guard let startDate = Expense.parseDate(startStr),
              let endDate = Expense.parseDate(endStr) else { return }

        // 시작과 끝을 정렬
        let lower = min(startDate, endDate)
        let upper = max(startDate, endDate)
        selectedDateRange = lower...upper
    }

    private func barColor(for dateString: String) -> Color {
        guard let range = selectedDateRange else { return .primary500 }
        guard let date = Expense.parseDate(dateString) else { return .primary500 }

        let calendar = Calendar.current
        let dateDay = calendar.startOfDay(for: date)
        let rangeStart = calendar.startOfDay(for: range.lowerBound)
        let rangeEnd = calendar.startOfDay(for: range.upperBound)

        // 범위 내에 있으면 primary500, 아니면 primary100
        return (dateDay >= rangeStart && dateDay <= rangeEnd) ? .primary500 : .primary100
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
        selectedDateRange: $selectedDateRange
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
        selectedDateRange: $selectedDateRange
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

    ScrollView(.horizontal, showsIndicators: true) {
        ExpenseChartView(
            expense: expenses,
            startDate: startDate,
            endDate: endDate,
            selectedDateRange: $selectedDateRange
        )
        .frame(width: 700)
        .padding()
    }
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
        selectedDateRange: $selectedDateRange
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
        selectedDateRange: $selectedDateRange
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
