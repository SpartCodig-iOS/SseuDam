//
//  DateRangePicker.swift
//  ExpenseListFeature
//
//  Created by Claude on 12/16/24.
//

import SwiftUI
import UIKit

// MARK: - DateRangePicker (SwiftUI Wrapper)

struct DateRangePicker: View {
    let startDate: Date
    let endDate: Date
    @Binding var selectedRange: ClosedRange<Date>?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            CalendarView(
                startDate: startDate,
                endDate: endDate,
                selectedRange: $selectedRange
            )
            .navigationTitle("기간 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - CalendarView (UIViewRepresentable)

struct CalendarView: UIViewRepresentable {
    let startDate: Date
    let endDate: Date
    @Binding var selectedRange: ClosedRange<Date>?

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedRange: $selectedRange)
    }

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = Calendar.current
        calendarView.locale = Locale.current
        calendarView.fontDesign = .rounded

        // 날짜 범위 제한
        let dateInterval = DateInterval(start: startDate, end: endDate)
        calendarView.availableDateRange = dateInterval

        // MultiDate selection 설정
        let selection = UICalendarSelectionMultiDate(delegate: context.coordinator)
        calendarView.selectionBehavior = selection
        context.coordinator.selection = selection

        // 초기 선택 설정
        if let range = selectedRange {
            context.coordinator.loadInitialRange(range)
        }

        return calendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // selectedRange가 외부에서 변경되면 업데이트
        context.coordinator.externalRangeUpdate(selectedRange)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UICalendarSelectionMultiDateDelegate {
        @Binding var selectedRange: ClosedRange<Date>?
        var selection: UICalendarSelectionMultiDate?

        private var rangeStart: Date?
        private var rangeEnd: Date?
        private let calendar = Calendar.current

        init(selectedRange: Binding<ClosedRange<Date>?>) {
            self._selectedRange = selectedRange
        }

        // 초기 범위 로드
        func loadInitialRange(_ range: ClosedRange<Date>) {
            let start = calendar.startOfDay(for: range.lowerBound)
            let end = calendar.startOfDay(for: range.upperBound)

            rangeStart = start
            rangeEnd = end

            // 범위 내 모든 날짜 선택
            var dates: [DateComponents] = []
            var current = start
            while current <= end {
                let components = calendar.dateComponents([.year, .month, .day], from: current)
                dates.append(components)
                guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
                current = next
            }

            selection?.setSelectedDates(dates, animated: false)
        }

        // 외부에서 selectedRange 변경 시
        func externalRangeUpdate(_ newRange: ClosedRange<Date>?) {
            guard let range = newRange else {
                rangeStart = nil
                rangeEnd = nil
                selection?.setSelectedDates([], animated: false)
                return
            }

            // 현재 내부 상태와 다를 때만 업데이트
            if rangeStart != range.lowerBound || rangeEnd != range.upperBound {
                loadInitialRange(range)
            }
        }

        // 날짜 선택 가능 여부
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, canSelectDate dateComponents: DateComponents) -> Bool {
            return true
        }

        // 날짜 해제 가능 여부
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, canDeselectDate dateComponents: DateComponents) -> Bool {
            return true
        }

        // 날짜가 선택/해제되었을 때
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
            guard let selectedDate = calendar.date(from: dateComponents) else { return }
            let date = calendar.startOfDay(for: selectedDate)

            print("🔵 날짜 선택: \(date)")

            // 첫 번째 선택 (start)
            if rangeStart == nil {
                print("  📍 첫 번째 선택 (start)")
                rangeStart = date
                rangeEnd = date
                selection.setSelectedDates([dateComponents], animated: false)
                updateBinding()
            }
            // 두 번째 선택 (end)
            else if let start = rangeStart, calendar.isDate(start, inSameDayAs: rangeEnd ?? start) {
                print("  📍 두 번째 선택 (end)")
                if date < start {
                    rangeStart = date
                    rangeEnd = start
                } else {
                    rangeEnd = date
                }
                fillRange()
                updateBinding()
            }
            // 세 번째 이후 선택 (리셋)
            else {
                print("  🔄 세 번째 이후 선택 (리셋)")
                rangeStart = date
                rangeEnd = date
                selection.setSelectedDates([dateComponents], animated: false)
                updateBinding()
            }
        }

        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
            print("❌ 날짜 해제")
            // 날짜 해제 시 전체 리셋
            rangeStart = nil
            rangeEnd = nil
            selection.setSelectedDates([], animated: false)
            selectedRange = nil
        }

        // 범위 채우기
        private func fillRange() {
            guard let start = rangeStart, let end = rangeEnd else { return }

            var dates: [DateComponents] = []
            var current = start
            while current <= end {
                let components = calendar.dateComponents([.year, .month, .day], from: current)
                dates.append(components)
                guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
                current = next
            }

            selection?.setSelectedDates(dates, animated: false)
            print("  🟢 범위 채우기 완료: \(dates.count)개 날짜")
        }

        // Binding 업데이트
        private func updateBinding() {
            guard let start = rangeStart, let end = rangeEnd else {
                selectedRange = nil
                print("  🔴 selectedRange -> nil")
                return
            }

            selectedRange = start...end
            print("  🟢 selectedRange 업데이트: \(start) ~ \(end)")
        }
    }
}
