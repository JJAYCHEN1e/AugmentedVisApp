//
//  PointScale.swift
//  PointScale
//
//  Created by jjaychen on 2021/10/12.
//

import CoreGraphics
import Foundation
import OrderedCollections

struct PointScale<T: Hashable> {
    var domain: OrderedSet<T>
    var range: [CGFloat]

    var step: CGFloat {
        (range[1] - range[0]) / CGFloat(domain.count - 1)
    }

    init(domain: OrderedSet<T> = [], range: [CGFloat] = [0, 1]) {
        guard range.count == 2 else { fatalError("`range.count == 2` failed.") }

        self.domain = domain
        self.range = range
    }

    func scale() -> (T) -> CGFloat? {
        { x in
            if let index = domain.firstIndex(of: x) {
                return range[0] + step * CGFloat(index)
            }
            return nil
        }
    }

    func invert() -> (CGFloat) -> (T) {
        { input in
            let index = Int((input + step * 0.5) / step)
            if index < 0 {
                return domain[0]
            } else if index >= domain.count {
                return domain.last!
            } else {
                return domain[index]
            }
        }
    }
}
