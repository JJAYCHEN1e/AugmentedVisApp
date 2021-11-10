//
//  VibrantTextButton.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/9.
//

import SwiftUI

struct VibrantTextButton: View {
    let text: String
    let action: (() -> Void)

    init(text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .cornerRadius(15)
        }
    }
}

struct VibrantTwoStatesTextButton: View {
    private enum ToggleState {
        case primary
        case secondary
    }

    @State private var displayState = ToggleState.primary
    @State private var primaryText: String
    @State private var secondaryText: String
    let action: (() -> Void)

    init(primaryText: String, secondaryText: String, action: @escaping () -> Void) {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.action = action
    }

    var body: some View {
        Button {
            action()
            withAnimation {
                displayState = displayState == .primary ? .secondary : .primary
            }
        } label: {
            Text(displayState == .primary ? primaryText : secondaryText)
                .animation(nil, value: UUID())
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
}

struct VibrantButton_Previews: PreviewProvider {
    static var previews: some View {
//        VibrantTextButton(text: "Hide", action: {})
        VibrantTwoStatesTextButton(primaryText: "Hide", secondaryText: "Show", action: {})
    }
}
