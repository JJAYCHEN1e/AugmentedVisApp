//
//  ARVisSettingTrackingComponent.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/6.
//

import Foundation
import SwiftUI

struct ARVisSettingTrackingComponent: View {
    static let sectionName = "Real time tracking"
    
    @Binding var realTimeTrackingEnabled: Bool
    var body: some View {
        Toggle("Real time tracking", isOn: $realTimeTrackingEnabled)
    }
}
