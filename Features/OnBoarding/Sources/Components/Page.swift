//
//  Page.swift
//  OnBoardingFeature
//
//  Created by Wonji Suh  on 12/15/25.
//

import Foundation

public enum Page: CaseIterable, Hashable {
  case travel
  case travelDetail
  case travelExpense

  public var next: Page? {
    switch self {
    case .travel: return .travelDetail
    case .travelDetail: return .travelExpense
    case .travelExpense: return nil
    }
  }

  public var ctaTitle: String {
    self == .travelExpense ? "시작하기" : "다음"
  }
}
