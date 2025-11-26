//
//  CategorySelector.swift
//  ExpenseFeature
//
//  Created by SseuDam on 2025.
//

import SwiftUI
import DesignSystem
import Domain

public struct CategorySelector: View {
    @Binding var selectedCategory: ExpenseCategory?
    
    public init(selectedCategory: Binding<ExpenseCategory?>) {
        self._selectedCategory = selectedCategory
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormLabel("카테고리")
            
            Menu {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack {
                            Text(category.displayName)
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                InputContainer {
                    HStack {
                        Text(selectedCategory?.displayName ?? "카테고리 선택")
                            .foregroundStyle(selectedCategory == nil ? Color.gray : Color.primary800)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.gray)
                            .font(.system(size: 14))
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var category: ExpenseCategory? = nil
    CategorySelector(selectedCategory: $category)
        .padding()
}
