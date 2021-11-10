//
//  PieChartItem.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/3.
//

import Foundation
import SwiftUI

struct PieChartItem: Codable, Equatable, Identifiable {
    var id = UUID()
    let data: Double
    let label: String
    let color: AVColor
    let additionalViewInfo: ViewInfoComponent?
    let itemDetailPieChartItemGroup: [PieChartItemGroup]

    init(data: Double,
         label: String,
         color: AVColor,
         additionalViewInfo: ViewInfoComponent? = nil,
         itemDetailPieChartItemGroup: [PieChartItemGroup] = []) {
        self.data = data
        self.label = label
        self.color = color
        self.additionalViewInfo = additionalViewInfo
        self.itemDetailPieChartItemGroup = itemDetailPieChartItemGroup
    }
}
