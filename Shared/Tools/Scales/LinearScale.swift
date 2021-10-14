//
//  LinearScale.swift
//  AugmentedVisApp
//
//  Created by jjaychen on 2021/10/11.
//

import CoreGraphics
import Foundation

/// Now, we only support 2 dimentional `LinearScale`.
struct LinearScale {
    typealias CGF2CGF = (CGFloat) -> CGFloat

    var domain: [CGFloat]
    var range: [CGFloat]

    var dimension: Int {
        min(domain.count, range.count)
    }

    var domainExtent: Extent<CGFloat> {
        let left = domain[0]
        let right = domain[dimension - 1]
        return Extent(min: min(left, right), max: max(left, right))
    }

    public init(domain: [CGFloat] = [0, 1], range: [CGFloat] = [0, 1]) {
        self.domain = domain
        self.range = range

        guard dimension == 2 else {
            fatalError("Assetsion `dimension == 2` failed. Currently we only support 2D LinearScale. `domain.count` = \(domain.count), `range.count` = \(range.count).")
        }
    }

    func scale() -> CGF2CGF {
        bimap(domain: domain, range: range)
    }

    func scale(tick: Tick) -> CGF2CGF {
        bimap(domain: [tick.start, tick.stop], range: range)
    }

    func invert() -> CGF2CGF {
        bimap(domain: range, range: domain)
    }

    /// `normalize(a, b)(x)` takes a domain value `x` in `[a,b]` and returns the corresponding parameter `t` in `[0,1]`.
    private func normalize(a: CGFloat, b: CGFloat) -> CGF2CGF {
        { ($0 - a) / (b - a) }
    }

    /// `interpolate(a, b)(t)` takes a parameter `t` in `[0,1]` and returns the corresponding range value `x` in `[a,b]`.
    private func interpolate(a: CGFloat, b: CGFloat) -> CGF2CGF {
        { a + $0 * (b - a) }
    }

    private func bimap(domain: [CGFloat], range: [CGFloat]) -> CGF2CGF {
        let n = normalize(a: domain[0], b: domain[1])
        let i = interpolate(a: range[0], b: range[1])
        return { i(n($0)) }
    }
}
