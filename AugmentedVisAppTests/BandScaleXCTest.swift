//
//  BandScaleXCTest.swift
//  BandScaleXCTest
//
//  Created by jjaychen on 2021/10/12.
//

import XCTest

class BandScaleXCTest: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNormalCase() {
        let scale = BandScale(domain: [1980, 1990, 2000, 2010, 2020], range: [0, 1]).scale()
        let accuracy: CGFloat = 0.000000001
        XCTAssertEqual(0, scale(1980)!, accuracy: accuracy)
        XCTAssertEqual(0.2, scale(1990)!, accuracy: accuracy)
        XCTAssertEqual(0.4, scale(2000)!, accuracy: accuracy)
        XCTAssertEqual(0.6, scale(2010)!, accuracy: accuracy)
        XCTAssertEqual(0.8, scale(2020)!, accuracy: accuracy)
    }
}
