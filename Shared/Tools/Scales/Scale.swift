//
//  Scale.swift
//  AugmentedVisApp
//
//  Created by jjaychen on 2021/10/11.
//

import CoreGraphics
import Foundation

struct Extent<T: Comparable> {
    let min: T
    let max: T
}

extension Extent where T: AdditiveArithmetic {
    var length: T {
        max - min
    }
}

/// Similar to https://github.com/d3/d3-array/blob/main/src/ticks.js
struct Tick {
    private static let e10 = sqrt(50)
    private static let e5 = sqrt(10)
    private static let e2 = sqrt(2)

    let start: CGFloat
    let stop: CGFloat
    let step: CGFloat
    let count: Int

    init(extent: Extent<CGFloat>, count: Int) {
        guard count > 0 else { fatalError("`count > 0` failed.") }
        self.count = count

        let step0 = extent.length / CGFloat(count)
        var step1 = pow(10, floor(log10(step0)))
        let error = step0 / step1

        if error >= Self.e10 {
            step1 *= 10
        } else if error >= Self.e5 {
            step1 *= 5
        } else if error >= Self.e2 {
            step1 *= 2
        }

        var rounedStart = round(extent.min / step1) * step1
        var roundedStop = round(extent.max / step1) * step1
        if rounedStart < extent.min { rounedStart += step1 }
        if roundedStop > extent.max { roundedStop -= step1 }

        start = rounedStart
        stop = roundedStop
        step = step1
    }
}
