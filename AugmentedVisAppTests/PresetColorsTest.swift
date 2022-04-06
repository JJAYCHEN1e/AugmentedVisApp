//
//  PresetColorsTest.swift
//  AugmentedVisAppTests
//
//  Created by 陈俊杰 on 2021/11/10.
//

import XCTest
import SwiftUI

class PresetColorsTest: XCTestCase {

    func testColorsSimilarity() throws {
        for (index, color) in Color.originalPresetColors.enumerated() {
            for (index2, color2) in Color.originalPresetColors.enumerated() where index != index2 {
                let components1 = color.components
                let components2 = color2.components

                XCTAssertTrue(pow(components1.red - components2.red, 2) + pow(components1.green - components2.green, 2) + pow(components1.blue - components2.blue, 2) > 0.005, "\(index) and \(index2)")
            }
        }
    }

    func testColorsBrightness() throws {
        for (index, color) in Color.originalPresetColors.enumerated() {
            let components = color.components

            XCTAssertFalse(components.red > 0.7 && components.green > 0.7 && components.blue > 0.7, "Index :\(index)")
        }
    }

}
