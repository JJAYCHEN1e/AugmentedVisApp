//
//  ARVisSettingHideableComponent.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/6.
//

import Foundation
import SwiftUI

struct ToggleableItem {
    let name: String
    let value: Binding<Bool>
}

struct ToggleableSection {
    let section: String
    let items: [ToggleableItem]
}

private struct IdentifiableToggleableItem: Identifiable {
    let id = UUID()
    let toggleableItem: ToggleableItem

    var name: String {
        toggleableItem.name
    }

    var itemIsHidden: Binding<Bool> {
        toggleableItem.value
    }
}

struct ARVisSettingToggleableComponent: View {
    static let sectionName = "Toggleable Settings"
    private let items: [IdentifiableToggleableItem]

    init(items: [ToggleableItem]) {
        self.items = items.map { .init(toggleableItem: $0) }
    }

    var body: some View {
        ForEach(items) { item in
            Toggle(item.name, isOn: item.itemIsHidden)
        }
    }
}
