//
//  PointScaleXCTest.swift
//  PointScaleXCTest
//
//  Created by jjaychen on 2021/10/12.
//

import XCTest

class PointScaleXCTest: XCTestCase {
    let accuracy: CGFloat = 0.000000001

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNormalCase() {
        let scale = PointScale(domain: [1980, 1990, 2000, 2010, 2020], range: [0, 1]).scale()
        XCTAssertEqual(0, scale(1980)!, accuracy: accuracy)
        XCTAssertEqual(0.25, scale(1990)!, accuracy: accuracy)
        XCTAssertEqual(0.5, scale(2000)!, accuracy: accuracy)
        XCTAssertEqual(0.75, scale(2010)!, accuracy: accuracy)
        XCTAssertEqual(1, scale(2020)!, accuracy: accuracy)
    }

    func testStringCase() {
        let scale = PointScale(domain: ["Mon", "Tue", "Wed", "Thu", "Fri"], range: [0, 1]).scale()
        let accuracy: CGFloat = 0.000000001
        XCTAssertEqual(0, scale("Mon")!, accuracy: accuracy)
        XCTAssertEqual(0.25, scale("Tue")!, accuracy: accuracy)
        XCTAssertEqual(0.5, scale("Wed")!, accuracy: accuracy)
        XCTAssertEqual(0.75, scale("Thu")!, accuracy: accuracy)
        XCTAssertEqual(1, scale("Fri")!, accuracy: accuracy)
    }
}
