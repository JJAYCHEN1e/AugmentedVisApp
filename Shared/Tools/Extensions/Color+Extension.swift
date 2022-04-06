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
