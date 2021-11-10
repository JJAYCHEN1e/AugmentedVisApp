//
//  SamplePieChartDataHelper.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/3.
//

import Foundation
import SwiftCSV
import SwiftUI

// swiftlint:disable force_try
class SamplePieChartDataHelper {
    private struct TGSubmoduleItem {
        let submodule: String
        let category: String
        let fileCount: Int
        let line: Int
        let code: Int
        let commentsLine: Int
        let blankLine: Int
    }

    private struct TGCategoryItem {
        let category: String
        let submodulesCount: Int
        let fileCount: Int
        let line: Int
        let code: Int
        let commentsLine: Int
        let blankLine: Int

        static let sourceCodeLink = "https://github.com/TelegramMessenger/Telegram-iOS"
    }

    static private var tgSubmoduleItems: [TGSubmoduleItem] {
        let resource = try! CSV(name: "Telegram_Submodules",
                                extension: "csv",
                                bundle: .main,
                                delimiter: ",",
                                encoding: .utf8)!

        var items: [TGSubmoduleItem] = []
        resource.namedRows.forEach { row in
            items.append(TGSubmoduleItem(submodule: row["Submodule"]!,
                                         category: row["Category"]!,
                                         fileCount: Int(row["Files"]!)!,
                                         line: Int(row["Lines"]!)!,
                                         code: Int(row["Code"]!)!,
                                         commentsLine: Int(row["Comments"]!)!,
                                         blankLine: Int(row["Blanks"]!)!))
        }

        return items
    }

    static private func tgSubmoduleItems(in category: String) -> [TGSubmoduleItem] {
        tgSubmoduleItems.filter { $0.category == category }
    }

    static private func SamplePieChartDataTGCategoryItems() -> [TGCategoryItem] {
        var tgCategoryItemsDictionary: [String: [TGSubmoduleItem]] = [:]

        for item in tgSubmoduleItems {
            if tgCategoryItemsDictionary[item.category] == nil {
                tgCategoryItemsDictionary[item.category] = []
            }

            tgCategoryItemsDictionary[item.category]!.append(item)
        }

        let tgCategoryItems: [TGCategoryItem] =  tgCategoryItemsDictionary.map { TGCategoryItem(category: $0.key,
                                                       submodulesCount: $0.value.count,
                                                       fileCount: $0.value.reduce(0, { $0 + $1.fileCount}),
                                                       line: $0.value.reduce(0, { $0 + $1.line}),
                                                       code: $0.value.reduce(0, { $0 + $1.code}),
                                                       commentsLine: $0.value.reduce(0, { $0 + $1.commentsLine}),
                                                       blankLine: $0.value.reduce(0, { $0 + $1.blankLine})) }
        return tgCategoryItems
    }

    // 所有 Category 代码行数的情况
    static func SamplePieChartDataTGCategoryLocItemGroup() -> PieChartItemGroup {
        let tgCategoryItems = SamplePieChartDataTGCategoryItems()

        let colors = Color.consistentColors(labels: tgCategoryItems.map { $0.category })

        var locItems: [PieChartItem] = tgCategoryItems.enumerated().map { index, item in
            .init(data: Double(item.line),
                  label: item.category,
                  color: AVColor(colors[index]),
                  additionalViewInfo: .vStack(elements:
                                                [
                                                    .text(content: "***\(item.category)*** Category", fontStyle: .init(size: 24, weight: .bold)),
                                                    .text(content: "Totally \(item.submodulesCount) submodules, \(item.fileCount) files and \(item.line) lines.", multilineTextAlignment: .leading),
                                                    .text(content: "[Source Code(GitHub)](https://github.com/TelegramMessenger/Telegram-iOS)")
                                                ],
                                              alignment: .leading),
                  itemDetailPieChartItemGroup: [
                    SamlePieChartDataTGCategorySubmoduleLocItemGroup(in: item.category),
                    SamlePieChartDataTGCategorySubmoduleFilesItemGroup(in: item.category)
                  ]
            )
        }

        locItems.sort { $0.data > $1.data }

        let tgLocGroup = PieChartItemGroup(items: locItems, title: "Telegram iOS Source Code", subtitle: "LOC per Category", dataDescription: "%.0f", dataDescriptionSuffix: " Lines")

        return tgLocGroup
    }

    // 所有 Category 文件个数的情况
    static func SamplePieChartDataTGCategoryFileCountItemGroup() -> PieChartItemGroup {
        let tgCategoryItems = SamplePieChartDataTGCategoryItems()

        let colors = Color.consistentColors(labels: tgCategoryItems.map { $0.category })

        var fileCountItems: [PieChartItem] = tgCategoryItems.enumerated().map { index, item in
            .init(data: Double(item.fileCount),
                  label: item.category,
                  color: AVColor(colors[index]),
                  additionalViewInfo: .vStack(elements:
                                                [
                                                    .text(content: "***\(item.category)*** Category", fontStyle: .init(size: 24, weight: .bold)),
                                                    .text(content: "Totally \(item.submodulesCount) submodules, \(item.fileCount) files and \(item.line) lines.", multilineTextAlignment: .leading),
                                                    .text(content: "[Source Code(GitHub)](https://github.com/TelegramMessenger/Telegram-iOS)")
                                                ],
                                              alignment: .leading),
                  itemDetailPieChartItemGroup: [
                    SamlePieChartDataTGCategorySubmoduleFilesItemGroup(in: item.category),
                    SamlePieChartDataTGCategorySubmoduleLocItemGroup(in: item.category)
                  ]
            )
        }

        fileCountItems.sort { $0.data > $1.data }

        let tgFileCountGroup = PieChartItemGroup(items: fileCountItems, title: "Telegram iOS Source Code", subtitle: "File Count per Category", dataDescription: "%.0f", dataDescriptionSuffix: " Files")

        return tgFileCountGroup
    }

    // 所有 Category Submodule 个数的情况
    static func SamlePieChartDataTGCategorySubmoduleItemGroup() -> PieChartItemGroup {
        let tgCategoryItems = SamplePieChartDataTGCategoryItems()

        let colors = Color.consistentColors(labels: tgCategoryItems.map { $0.category })

        var submoduleItems: [PieChartItem] = tgCategoryItems.enumerated().map { index, item in
                .init(data: Double(item.submodulesCount),
                      label: item.category,
                      color: AVColor(colors[index]),
                      additionalViewInfo: .vStack(elements:
                                                    [
                                                        .text(content: "***\(item.category)*** Category", fontStyle: .init(size: 24, weight: .bold)),
                                                        .text(content: "Totally \(item.submodulesCount) submodules, \(item.fileCount) files and \(item.line) lines.", multilineTextAlignment: .leading),
                                                        .text(content: "[Source Code(GitHub)](https://github.com/TelegramMessenger/Telegram-iOS)")
                                                    ],
                                                  alignment: .leading)
                )
        }

        submoduleItems.sort { $0.data > $1.data }

        let tgSubmoduleGroup = PieChartItemGroup(items: submoduleItems, title: "Telegram iOS Source Code", subtitle: "Submodules per Category", dataDescription: "%.0f", dataDescriptionSuffix: " Submodules")

        return tgSubmoduleGroup
    }

    // 单个 Category 文件个数的情况
    static func SamlePieChartDataTGCategorySubmoduleFilesItemGroup(in category: String) -> PieChartItemGroup {
        let submodules = tgSubmoduleItems(in: category)

        let colors = Color.consistentColors(labels: submodules.map { $0.submodule })

        var submoduleItems: [PieChartItem] = submodules.enumerated().map { index, item in
                .init(data: Double(item.fileCount),
                      label: item.submodule,
                      color: AVColor(colors[index])
                )
        }

        submoduleItems.sort { $0.data > $1.data }

        let tgSubmoduleGroup = PieChartItemGroup(items: submoduleItems, title: "Telegram iOS Source Code", subtitle: "Submodules Files for Category \(category).", dataDescription: "%.0f", dataDescriptionSuffix: " Files")

        return tgSubmoduleGroup
    }

    // 单个 Category 代码行数个数的情况
    static func SamlePieChartDataTGCategorySubmoduleLocItemGroup(in category: String) -> PieChartItemGroup {
        let submodules = tgSubmoduleItems(in: category)

        let colors = Color.consistentColors(labels: submodules.map { $0.submodule })

        var submoduleLocItems: [PieChartItem] = submodules.enumerated().map { index, item in
                .init(data: Double(item.line),
                      label: item.submodule,
                      color: AVColor(colors[index])
                )
        }

        submoduleLocItems.sort { $0.data > $1.data }

        let tgSubmoduleGroup = PieChartItemGroup(items: submoduleLocItems, title: "Telegram iOS Source Code", subtitle: "Submodules LOC for Category \(category).", dataDescription: "%.0f", dataDescriptionSuffix: " Lines")

        return tgSubmoduleGroup
    }
}
