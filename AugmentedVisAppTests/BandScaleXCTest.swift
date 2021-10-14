//
//  BandScaleXCTest.swift
//  BandScaleXCTest
//
//  Created by jjaychen on 2021/10/12.
//

import XCTest

class BandScaleXCTest: XCTestCase {

    let accuracy: CGFloat = 0.000000001

    func testIntCase() {
        let scale = BandScale(domain: [1980, 1990, 2000, 2010, 2020], range: [0, 1]).scale()
        XCTAssertEqual(0, scale(1980)!, accuracy: accuracy)
        XCTAssertEqual(0.2, scale(1990)!, accuracy: accuracy)
        XCTAssertEqual(0.4, scale(2000)!, accuracy: accuracy)
        XCTAssertEqual(0.6, scale(2010)!, accuracy: accuracy)
        XCTAssertEqual(0.8, scale(2020)!, accuracy: accuracy)
    }

}
