//
//  PieChartViewModel.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/3.
//

import SwiftUI

class PieChartViewModel: ObservableObject {
    private(set) var historyItemGroups: [(groups: [PieChartItemGroup], groupIndex: Int, selectedIndex: Int)]

    private var _groupIndex: Int

    // Only set outside.
    var groupIndex: Int {
        get {
            _groupIndex
        }
        set {
            guard _groupIndex < itemGroups.count && _groupIndex != newValue else { return }
            _groupIndex = newValue

            selectedIndex = -1
        }
    }

    @Published var itemGroups: [PieChartItemGroup]
    @Published public var selectedIndex: Int = -1

    let borderColor: Color
    let sliceOffset: Double = -.pi / 2


    internal init(
        itemGroups: [PieChartItemGroup],
        defaultItemGroupIndex: Int,
        borderColor: Color)
    {
        self._groupIndex = defaultItemGroupIndex
        self.itemGroups = itemGroups

        self.borderColor = borderColor
        self.historyItemGroups = []
    }
}

extension PieChartViewModel {
    func showNewItemGroups(itemGroups: [PieChartItemGroup]) {
        guard itemGroups.count > 0 else { return }

        self.historyItemGroups.append((groups: self.itemGroups, groupIndex: groupIndex, selectedIndex: selectedIndex))

        selectedIndex = -1
        _groupIndex = 0

        self.itemGroups = itemGroups

    }

    func showPreviousItemGroups() {
        guard historyItemGroups.count > 0 else { return }

        self.itemGroups = historyItemGroups.last!.groups
        selectedIndex = historyItemGroups.last!.selectedIndex
        _groupIndex = historyItemGroups.last!.groupIndex

        self.historyItemGroups.removeLast()
    }
}

extension PieChartViewModel {
    private class IDPool {
        static var ids: [UUID] = {
            var result: [UUID] = []
            for _ in 0..<100 {
                result.append(UUID())
            }

            return result
        }()
    }

    struct DumbIdentifiable: Identifiable, Equatable {
        let id: UUID
    }

    var title: String {
        itemGroups[groupIndex].title
    }

    var data: [Double] {
        itemGroups[groupIndex].items.map { $0.data }
    }

    var labels: [String] {
        itemGroups[groupIndex].items.map { $0.label }
    }

    var colors: [Color] {
        itemGroups[groupIndex].items.map { Color($0.color) }
    }

    var additionalViewInfos: [ViewInfoComponent?] {
        itemGroups[groupIndex].items.map { $0.additionalViewInfo }
    }

    var itemDetailPieChartItemGroups: [[PieChartItemGroup]] {
        itemGroups[groupIndex].items.map { $0.itemDetailPieChartItemGroup }
    }

    var dataDescriptionPrefix: String? {
        itemGroups[groupIndex].dataDescriptionPrefix
    }

    var dataDescription: String? {
        itemGroups[groupIndex].dataDescription
    }

    var dataDescriptionSuffix: String? {
        itemGroups[groupIndex].dataDescriptionSuffix
    }

    var items: [PieChartItem] {
        itemGroups[groupIndex].items
    }

    var idConsistentItems: [PieChartItem] {
        items.enumerated().map { index, item in
            var item = item
            item.id = IDPool.ids[index]
            return item
        }
    }

    var idConsistentDumbItems: [DumbIdentifiable] {
        IDPool.ids.map { DumbIdentifiable(id: $0) }
    }
}
