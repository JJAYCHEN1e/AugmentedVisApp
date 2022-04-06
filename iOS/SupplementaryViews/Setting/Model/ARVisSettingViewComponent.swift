//
//  ARVisSettingViewComponent.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/6.
//

import Foundation
import SwiftUI

struct AnyARVisSettingViewComponent: Identifiable {
    let sectionName: String
    private let sectionComponent: ARVisSettingViewComponent

    var view: some View {
        sectionComponent.view()
    }

    var id: String {
        sectionName
    }

    fileprivate init(sectionName: String? = nil, sectionComponent: ARVisSettingViewComponent) {
        self.sectionName = sectionName ?? sectionComponent.sectionName
        self.sectionComponent = sectionComponent
    }
}

extension AnyARVisSettingViewComponent {
    static func trackingComponent(sectionName: String? = nil, realTimeTrackingEnabled: Binding<Bool>) -> AnyARVisSettingViewComponent {
        .init(sectionName: sectionName, sectionComponent: .trackingComponent(realTimeTrackingEnabled: realTimeTrackingEnabled))
    }

    static func toggleableComponent(sectionName: String? = nil, toggleableItems: [ToggleableItem]) -> AnyARVisSettingViewComponent {
        .init(sectionName: sectionName, sectionComponent: .toggleableComponent(toggleableItems: toggleableItems))
    }
}

enum ARVisSettingViewComponent {
    case trackingComponent(realTimeTrackingEnabled: Binding<Bool>)
    case toggleableComponent(toggleableItems: [ToggleableItem])
}

extension ARVisSettingViewComponent {
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .trackingComponent(let realTimeTrackingEnabled):
            ARVisSettingTrackingComponent(realTimeTrackingEnabled: realTimeTrackingEnabled)
        case .toggleableComponent(let toggleableItems):
            ARVisSettingToggleableComponent(items: toggleableItems)
        }
    }

    var sectionName: String {
        switch self {
        case .trackingComponent:
            return ARVisSettingTrackingComponent.sectionName
        case .toggleableComponent:
            return ARVisSettingToggleableComponent.sectionName
        }
    }
}
