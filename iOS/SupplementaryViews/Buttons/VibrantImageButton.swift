//
//  VibrantImageButton.swift
//  AugmentedVisApp (iOS)
//
//  Created by 陈俊杰 on 2021/11/9.
//

import SwiftUI

struct VibrantImageButton: View {
    let systemName: String
    let action: (() -> Void)

    init(systemName: String, action: @escaping () -> Void) {
        self.systemName = systemName
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: systemName)
                .foregroundColor(.white)
                .frame(minWidth: 70, minHeight: 45)
                .background(.ultraThinMaterial)
                .cornerRadius(15)
        }
    }
}

struct VibrantImageButton_Previews: PreviewProvider {
    static var previews: some View {
        VibrantImageButton(systemName: "arrow.up.left.and.arrow.down.right", action: {})
    }
}
