//
//  OnBoardingView.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import DesignSystem

public struct OnBoardingView: View {
    public init() {}

    public var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("OnBoarding Feature")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
        .navigationTitle("OnBoarding")
    }
}

#Preview {
    NavigationView {
        OnBoardingView()
    }
}