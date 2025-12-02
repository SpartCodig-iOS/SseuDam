//
//  SettlementScreen.swift
//  MainFeature
//
//  Created by 홍석현 on 11/30/25.
//

import Foundation
import ComposableArchitecture
import TCACoordinators
import ExpenseFeature

@Reducer
public enum SettlementScreen {
    case settlement(SettlementFeature)
    case expense(ExpenseFeature)
}

extension SettlementScreen.State: Equatable {}
extension SettlementScreen.State: Hashable {}
