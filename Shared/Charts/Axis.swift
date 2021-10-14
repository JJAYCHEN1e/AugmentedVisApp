//
//  Axis.swift
//  AugmentedVisApp
//
//  Created by jjaychen on 2021/10/11.
//

import CoreGraphics
import Foundation

struct Axis {
    enum Direction {
        case x
        case y
    }

    let direction: Direction

    /// Tick count can be changed after calculation... so we need to calculate it dynamically.
    var tickCount: Int {
        Int((tick.stop - tick.start) / tick.step)
    }

    let tick: Tick

    private(set) var scale: LinearScale

    let gridCount: Int

    var gridStepLength: CGFloat {
        scale.domainExtent.length / CGFloat(gridCount - 1)
    }

    var scaleFunction: LinearScale.CGF2CGF {
        scale.scale()
    }

    init(direction: Direction, scale: LinearScale, tickCount: Int, gridCount: Int = 0) {
        guard tickCount > 0 else { fatalError("`tickCount` > 0 failed.") }
        guard gridCount > 0 else { fatalError("`gridCount` > 0 failed.") }

        self.direction = direction
        tick = Tick(extent: scale.domainExtent, count: tickCount)
        self.scale = scale
        self.gridCount = gridCount
    }

    init(direction: Direction, scale: LinearScale, tick: Tick, gridCount: Int = 0) {
        guard gridCount > 0 else { fatalError("`gridCount` > 0 failed.") }
        self.direction = direction
        self.tick = tick
        self.scale = scale
        self.gridCount = gridCount
    }
}
