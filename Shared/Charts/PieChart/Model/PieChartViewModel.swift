//
//  PieChartViewModel.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/3.
//

import SwiftUI

// swiftlint:disable large_tuple
class PieChartViewModel: ObservableObject, ChartViewModel {
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
    @Published var selectedIndex: Int = -1

    @Published var showLabelEnabled = true

    var itemLabelShowingToggleableSection: ToggleableSection {
        .init(section: "Item label showing", items: [
            .init(name: "Show item labels", value: .init(get: { self.showLabelEnabled },
                                                         set: { value in
                                                             withAnimation(.linear(duration: 0.3)) {
                                                                 self.showLabelEnabled = value
                                                             }
                                                         }))
        ])

    }

    let borderColor: Color
    let sliceOffset: Double = -.pi / 2

    internal init(
        itemGroups: [PieChartItemGroup],
        defaultItemGroupIndex: Int,
        borderColor: Color) {
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
    static private let maxItemCount = 100
    private class IDPool {
        static var ids: [UUID] = {
            var result: [UUID] = []
            for _ in 0..<maxItemCount {
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

    var subtitle: String? {
        itemGroups[groupIndex].subtitle
    }

    var data: [Double] {
        Array(itemGroups[groupIndex].items.map { $0.data }.prefix(PieChartViewModel.maxItemCount))
    }

    var labels: [String] {
        Array(itemGroups[groupIndex].items.map { $0.label }.prefix(PieChartViewModel.maxItemCount))
    }

    var colors: [Color] {
        Array(itemGroups[groupIndex].items.map { Color($0.color) }.prefix(PieChartViewModel.maxItemCount))
    }

    var additionalViewInfos: [ViewInfoComponent?] {
        Array(itemGroups[groupIndex].items.map { $0.additionalViewInfo }.prefix(PieChartViewModel.maxItemCount))
    }

    var itemDetailPieChartItemGroups: [[PieChartItemGroup]] {
        Array(itemGroups[groupIndex].items.map { $0.itemDetailPieChartItemGroup }.prefix(PieChartViewModel.maxItemCount))
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
        Array(itemGroups[groupIndex].items.prefix(PieChartViewModel.maxItemCount))
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
