//
//  CustomModalModifier.swift
//  DesignSystem
//
//  Created by Wonji Suh on 11/25/25.
//

import SwiftUI

public enum ModalHeight {
    case fraction(CGFloat)  
    case fixed(CGFloat)
    case auto
}

public struct CustomModalModifier<Item: Identifiable, ModalContent: View>: ViewModifier {
    @Binding var item: Item?
    let height: ModalHeight
    let showDragIndicator: Bool
    let modalContent: (Item) -> ModalContent

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var modalOffset: CGFloat = 0

    public init(
        item: Binding<Item?>,
        height: ModalHeight = .auto,
        showDragIndicator: Bool = true,
        @ViewBuilder modalContent: @escaping (Item) -> ModalContent
    ) {
        self._item = item
        self.height = height
        self.showDragIndicator = showDragIndicator
        self.modalContent = modalContent
    }

    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .overlay(
                    item != nil ?
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    modalOffset = 300
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    item = nil
                                    modalOffset = 0
                                }
                            }

                        VStack(spacing: 0) {
                            Spacer()

                            if let currentItem = item {
                                VStack(spacing: 0) {
                                    if showDragIndicator {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 36, height: 4)
                                            .padding(.top, 8)
                                            .padding(.bottom, 12)
                                    }

                                    modalContent(currentItem)
                                        .frame(height: modalHeightValue(for: geometry))

                                    Spacer()
                                        .frame(height: geometry.safeAreaInsets.bottom)
                                }
                                .background(.white)
                                .clipShape(
                                    UnevenRoundedRectangle(
                                        topLeadingRadius: 20,
                                        topTrailingRadius: 20
                                    )
                                )
                                .offset(y: modalOffset + max(0, dragOffset.height))
                                .animation(isDragging ? nil : .spring(response: 0.5, dampingFraction: 0.8), value: dragOffset)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: modalOffset)
                                .onAppear {
                                    modalOffset = 300 // Start from bottom
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        modalOffset = 0 // Slide up naturally
                                    }
                                }
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            isDragging = true
                                            if value.translation.height > 0 {
                                                dragOffset = value.translation
                                            }
                                        }
                                        .onEnded { value in
                                            isDragging = false
                                            let threshold: CGFloat = 100

                                            if value.translation.height > threshold {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                    modalOffset = 300
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    item = nil
                                                    modalOffset = 0
                                                    dragOffset = .zero
                                                }
                                            } else {
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                    dragOffset = .zero
                                                }
                                            }
                                        }
                                )
                            }
                        }
                        .ignoresSafeArea(.container, edges: .bottom)
                    }
                    : nil
                )
        }
    }

    private func modalHeightValue(for geometry: GeometryProxy) -> CGFloat? {
        let safeAreaBottom = geometry.safeAreaInsets.bottom
        let availableHeight = geometry.size.height - safeAreaBottom

        switch height {
        case .fraction(let fraction):
            return min(availableHeight * fraction, availableHeight)
        case .fixed(let points):
            return min(points, availableHeight)
        case .auto:
            return nil 
        }
    }
}

public extension View {
    func customModal<Item: Identifiable, ModalContent: View>(
        item: Binding<Item?>,
        height: ModalHeight = .auto,
        showDragIndicator: Bool = true,
        @ViewBuilder content: @escaping (Item) -> ModalContent
    ) -> some View {
        modifier(
            CustomModalModifier(
                item: item,
                height: height,
                showDragIndicator: showDragIndicator,
                modalContent: content
            )
        )
    }
}
