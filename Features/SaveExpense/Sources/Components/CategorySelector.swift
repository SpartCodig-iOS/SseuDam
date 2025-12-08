//
//  CategorySelector.swift
//  SaveExpenseFeature
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
    
    @State private var showDialog = false
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormLabel("카테고리")
            
            Button {
                showDialog = true
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
            .confirmationDialog("카테고리 선택", isPresented: $showDialog) {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    Button(category.displayName) {
                        selectedCategory = category
                    }
                }
                Button("취소", role: .cancel) {}
            }
        }
    }
}

#Preview {
    @Previewable @State var category: ExpenseCategory? = nil
    CategorySelector(selectedCategory: $category)
        .padding()
}
