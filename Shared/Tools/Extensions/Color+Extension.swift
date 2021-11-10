//
//  Color+Extension.swift
//  Color+Extension
//
//  Created by jjaychen on 2021/10/12.
//

import SwiftUI

#if os(iOS)
import UIKit
typealias NativeColor = UIColor
#elseif os(macOS)
import AppKit
typealias NativeColor = NSColor
#endif

extension Color {
#if os(macOS)
    init(_ nsColor: NSColor) {
        self.init(nsColor: nsColor)
    }

    init(hex hexString: String) {
        if let nsColor = NSColor(hexString) {
            self.init(nsColor)
        } else {
            self = .primary
        }
    }

#elseif os(iOS)
    init(_ uiColor: UIColor) {
        self.init(uiColor: uiColor)
    }

    init(hex hexString: String) {
        self.init(UIColor(hexString))
    }
#endif
}

// Random Colors
extension Color {
    static func randomColors(count: Int) -> [Color] {
        var colors: [Color] = [
            Color(red: 0.121569, green: 0.466667, blue: 0.705882, opacity: 1),
            Color(red: 1, green: 0.498039, blue: 0.054902, opacity: 1),
            Color(red: 0.172549, green: 0.627451, blue: 0.172549, opacity: 1),
            Color(red: 0.839216, green: 0.152941, blue: 0.156863, opacity: 1),
            Color(red: 0.580392, green: 0.403922, blue: 0.741176, opacity: 1),
            Color(red: 0.54902, green: 0.337255, blue: 0.294118, opacity: 1),
            Color(red: 0.890196, green: 0.466667, blue: 0.760784, opacity: 1),
            Color(red: 0.498039, green: 0.498039, blue: 0.498039, opacity: 1),
            Color(red: 0.737255, green: 0.741176, blue: 0.133333, opacity: 1),
            Color(red: 0.0901961, green: 0.745098, blue: 0.811765, opacity: 1)
        ].shuffled()

        while colors.count < count {
            colors.append(contentsOf: colors)
        }

        return [Color](colors.prefix(count))
    }
}

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)

        return (r, g, b, o)
    }
}
