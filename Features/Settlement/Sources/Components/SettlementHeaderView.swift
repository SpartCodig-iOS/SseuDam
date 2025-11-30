//
//  SettlementHeaderView.swift
//  SettlementFeature
//
//  Created by 홍석현 on 11/28/25.
//

import SwiftUI
import DesignSystem

public struct SettlementHeaderView: View {
    let totalAmount: Int
    let startDate: Date
    let endDate: Date
    let myExpenseAmount: Int
    @Binding var selectedDate: Date
    
    public init(
        totalAmount: Int,
        startDate: Date,
        endDate: Date,
        myExpenseAmount: Int,
        selectedDate: Binding<Date>
    ) {
        self.totalAmount = totalAmount
        self.startDate = startDate
        self.endDate = endDate
        self.myExpenseAmount = myExpenseAmount
        self._selectedDate = selectedDate
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                // 날짜 선택 (드롭다운 느낌)
                Menu {
                    ForEach(datesRange, id: \.self) { date in
                        Button {
                            selectedDate = date
                        } label: {
                            HStack {
                                Text(dateFormatter.string(from: date))
                                if Calendar.current.isDate(selectedDate, inSameDayAs: date) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(dateFormatter.string(from: selectedDate))
                            .font(.app(.body, weight: .medium))
                            .foregroundStyle(Color.gray7)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundStyle(Color.gray5)
                    }
                }
                
                
                // 총 지출 금액
                Text("₩\(totalAmount.formatted())")
                    .font(.app(.title1, weight: .semibold))
                    .foregroundStyle(.black)
            }
            .padding(.vertical, 12)
            
            // 하단 정보 (여행 기간 / 내 지출)
            HStack {
                VStack(alignment: .center, spacing: 8) {
                    Text("여행 기간")
                        .font(.app(.caption1, weight: .semibold))
                        .foregroundStyle(Color.gray7)
                    Text("\(dateFormatter.string(from: startDate)) -\n\(dateFormatter.string(from: endDate))")
                        .font(.app(.title3, weight: .semibold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                VStack(alignment: .center, spacing: 8) {
                    Text("내 지출")
                        .font(.app(.caption1, weight: .semibold))
                        .foregroundStyle(Color.gray7)
                    Text("₩\(myExpenseAmount.formatted())")
                        .font(.app(.title3, weight: .semibold))
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
    }
    
    private var datesRange: [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        // 시작일의 00:00:00으로 정규화
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        
        var currentDate = start
        while currentDate <= end {
            dates.append(currentDate)
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        return dates
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }
}

#Preview {
    SettlementHeaderView(
        totalAmount: 255450,
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 5),
        myExpenseAmount: 255450,
        selectedDate: .constant(Date())
    )
}
