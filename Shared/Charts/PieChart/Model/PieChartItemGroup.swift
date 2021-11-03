//
//  PieChartItemGroup.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/3.
//

import Foundation

struct PieChartItemGroup: Codable, Identifiable, Equatable {
    var id = UUID()
    let items: [PieChartItem]
    let title: String

    let dataDescriptionPrefix: String?
    let dataDescription: String?
    let dataDescriptionSuffix: String?

    internal init(items: [PieChartItem], title: String, dataDescriptionPrefix: String? = nil, dataDescription: String? = nil, dataDescriptionSuffix: String? = nil) {
        self.items = items
        self.title = title
        self.dataDescriptionPrefix = dataDescriptionPrefix
        self.dataDescription = dataDescription
        self.dataDescriptionSuffix = dataDescriptionSuffix
    }

}
