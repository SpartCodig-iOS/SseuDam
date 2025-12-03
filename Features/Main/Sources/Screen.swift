//
//  Screen.swift
//  MainFeature
//
//  Created by 홍석현 on 11/30/25.
//

import Foundation
import ComposableArchitecture
import TCACoordinators
import TravelFeature
import SettlementFeature
import ProfileFeature

@Reducer
public enum Screen {
    case travelList(TravelListFeature)
    case createTravel(TravelCreateFeature)
    case settlementCoordinator(SettlementCoordinator)
    case travelSetting(TravelSettingFeature)
    case profile(ProfileCoordinator)
}

extension Screen.State: Equatable {}
