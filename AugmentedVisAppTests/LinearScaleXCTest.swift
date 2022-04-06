//
//  LinearScaleXCTest.swift
//  LinearScaleXCTest
//
//  Created by jjaychen on 2021/10/14.
//

import XCTest

class LinearScaleXCTest: XCTestCase {

    let accuracy: CGFloat = 0.000000001

    func testNormalCase() {
        let linearScale = LinearScale(domain: [0, 1], range: [0, 1000]).scale()

        XCTAssertEqual(0, linearScale(0), accuracy: accuracy)
        XCTAssertEqual(100, linearScale(0.1), accuracy: accuracy)
        XCTAssertEqual(300, linearScale(0.3), accuracy: accuracy)
        XCTAssertEqual(1000, linearScale(1), accuracy: accuracy)
    }

    func testInvertCase() {
        let linearScaleInvert = LinearScale(domain: [0, 1], range: [0, 1000]).invert()

        XCTAssertEqual(0, linearScaleInvert(0), accuracy: accuracy)
        XCTAssertEqual(0.1, linearScaleInvert(100), accuracy: accuracy)
        XCTAssertEqual(0.3, linearScaleInvert(300), accuracy: accuracy)
        XCTAssertEqual(1, linearScaleInvert(1000), accuracy: accuracy)
    }

}
