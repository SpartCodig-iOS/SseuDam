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
    
    public init(label: String, date: Binding<Date>) {
        self.label = label
        self._date = date
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.primary800)
            
            DatePicker(
                "",
                selection: $date,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "ko_KR"))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray2.opacity(0.3))
            .cornerRadius(12)
        }
    }
}

#Preview {
    @Previewable @State var date = Date()
    
    DatePickerField(label: "날짜", date: $date)
        .padding()
}
