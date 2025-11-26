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
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormLabel(label)
            
            InputContainer {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.gray)
                    
                    Text(dateFormatter.string(from: date))
                        .foregroundStyle(Color.primary800)
                    
                    Spacer()
                }
                .overlay {
                    DatePicker(
                        "",
                        selection: $date,
                        in: ...Date(),
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
    DatePickerField(label: "지출일", date: $date)
        .padding()
}
