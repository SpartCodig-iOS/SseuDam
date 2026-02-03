//
//  ReceiptHeaderView.swift
//  SaveExpenseFeature
//
//  Created by 김민희 on 2/3/26.
//

import SwiftUI

struct ReceiptHeaderView: View {
    let image: UIImage
    let onZoom: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 229)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button(action: onZoom) {
                Image(asset: .zoomIn)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.appWhite)
                    .padding(20)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray2)
        )
    }
}

#Preview {
    ReceiptHeaderView(
        image: UIImage(systemName: "doc.text.image")!,
        onZoom: {}
    )
}
