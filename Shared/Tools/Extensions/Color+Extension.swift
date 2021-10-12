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
#elseif os(iOS)
	init(_ uiColor: UIColor) {
		self.init(uiColor: uiColor)
	}
#endif
}
