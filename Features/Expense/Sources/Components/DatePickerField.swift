//
//  DatePickerField.swift
//  ExpenseFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem

public struct DatePickerField: View {
    let label: String
    @Binding var date: Date
    let startDate: Date?
    let endDate: Date?
    
    public init(
        label: String,
        date: Binding<Date>,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) {
        self.label = label
        self._date = date
        self.startDate = startDate
        self.endDate = endDate
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }
    
    private var dateRange: ClosedRange<Date> {
        let start = startDate ?? Date.distantPast
        let end = endDate ?? Date.distantFuture
        return start...end
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormLabel(label)
            
            InputContainer {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.gray)
                    
                    Text(dateFormatter.string(from: date))
                        .foregroundStyle(Color.black)
                    
                    Spacer()
                }
                .overlay {
                    DatePicker(
                        "",
                        selection: $date,
                        in: dateRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .colorMultiply(.clear) // 텍스트 숨기고 터치 영역만 유지
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var date = Date()
    DatePickerField(
        label: "지출일",
        date: $date,
        startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
        endDate: Date()
    )
    .padding()
}
