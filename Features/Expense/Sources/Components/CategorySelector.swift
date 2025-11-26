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
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("카테고리")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.primary800)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    CategoryCell(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
}

private struct CategoryCell: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? Color.white : Color.primary800)
                
                Text(category.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? Color.white : Color.primary800)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? Color.primary500 : Color.gray2.opacity(0.3))
            .cornerRadius(12)
        }
    }
    
    private var iconName: String {
        switch category {
        case .accommodation: return "bed.double.fill"
        case .foodAndDrink: return "fork.knife"
        case .transportation: return "car.fill"
        case .activity: return "figure.walk"
        case .shopping: return "bag.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

#Preview {
    @Previewable @State var category: ExpenseCategory? = .foodAndDrink
    
    CategorySelector(selectedCategory: $category)
        .padding()
}
