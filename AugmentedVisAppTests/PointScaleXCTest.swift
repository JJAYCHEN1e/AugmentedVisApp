//
//  PointScaleXCTest.swift
//  PointScaleXCTest
//
//  Created by jjaychen on 2021/10/12.
//

import XCTest

class PointScaleXCTest: XCTestCase {

    let accuracy: CGFloat = 0.000000001

    func testIntCase() {
        let scale = PointScale(domain: [1980, 1990, 2000, 2010, 2020], range: [0, 1]).scale()
        XCTAssertEqual(0, scale(1980)!, accuracy: accuracy)
        XCTAssertEqual(0.25, scale(1990)!, accuracy: accuracy)
        XCTAssertEqual(0.5, scale(2000)!, accuracy: accuracy)
        XCTAssertEqual(0.75, scale(2010)!, accuracy: accuracy)
        XCTAssertEqual(1, scale(2020)!, accuracy: accuracy)
    }

    func testStringCase() {
        let scale = PointScale(domain: ["Mon", "Tue", "Wed", "Thu", "Fri"], range: [0, 1]).scale()
        XCTAssertEqual(0, scale("Mon")!, accuracy: accuracy)
        XCTAssertEqual(0.25, scale("Tue")!, accuracy: accuracy)
        XCTAssertEqual(0.5, scale("Wed")!, accuracy: accuracy)
        XCTAssertEqual(0.75, scale("Thu")!, accuracy: accuracy)
        XCTAssertEqual(1, scale("Fri")!, accuracy: accuracy)
    }

    func testIntInvertCase() {
        let scaleInvert = PointScale(domain: [1980, 1990, 2000, 2010, 2020], range: [0, 1]).invert()
        XCTAssertEqual(1980, scaleInvert(0))
        XCTAssertEqual(1980, scaleInvert(0.12))
        XCTAssertEqual(1990, scaleInvert(0.125))
        XCTAssertEqual(1990, scaleInvert(0.126))
        XCTAssertEqual(1990, scaleInvert(0.25))
        XCTAssertEqual(1990, scaleInvert(0.374))
        XCTAssertEqual(2000, scaleInvert(0.375))
        XCTAssertEqual(2000, scaleInvert(0.5))
        XCTAssertEqual(2020, scaleInvert(1.0))
    }

}
