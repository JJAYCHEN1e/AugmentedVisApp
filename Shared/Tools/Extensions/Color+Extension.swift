//
//  Color+Extension.swift
//  Color+Extension
//
//  Created by jjaychen on 2021/10/12.
//

import SwiftUI

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
