//
//  BandScale.swift
//  BandScale
//
//  Created by jjaychen on 2021/10/12.
//

import Foundation
import CoreGraphics
import OrderedCollections

struct BandScale<T: Hashable> {
	
	var domain: OrderedSet<T>
	var range: [CGFloat]
	
	var step: CGFloat {
		get {
			(range[1] - range[0]) / CGFloat(domain.count)
		}
	}
	
	init(domain: OrderedSet<T> = [], range: [CGFloat] = [0, 1]) {
		guard range.count == 2 else { fatalError("`range.count == 2` failed.") }
		
		self.domain = domain
		self.range = range
	}
	
	func scale() -> (T) -> CGFloat? {
		return { x in
			if let index = domain.firstIndex(of: x) {
				return range[0] + step * CGFloat(index)
			}
			return nil
		}
	}
}
