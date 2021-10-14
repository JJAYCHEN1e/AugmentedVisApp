//
//  String+Extension.swift
//  AugmentedVisApp
//
//  Created by jjaychen on 2021/10/11.
//

import Foundation
#if os(iOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

extension String {
#if os(iOS)
	func widthOfString(usingFont font: UIFont) -> CGFloat {
		let fontAttributes = [NSAttributedString.Key.font: font]
		let size = self.size(withAttributes: fontAttributes)
		return size.width
	}
#endif
	
#if os(macOS)
	func widthOfString(usingFont font: NSFont) -> CGFloat {
		let fontAttributes = [NSAttributedString.Key.font: font]
		let size = self.size(withAttributes: fontAttributes)
		return size.width
	}
#endif
}
