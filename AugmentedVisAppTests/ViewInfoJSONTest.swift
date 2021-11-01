//
//  ViewInfoJSONTest.swift
//  ViewInfoJSONTest
//
//  Created by jjaychen on 2021/10/24.
//

import XCTest
@testable import AugmentedVisApp

class ViewInfoJSONTest: XCTestCase {

    func testSingleViewInfoEncodeDecodeConsistency() throws {
        do {
            let viewInfoText = ViewInfo.text(content: "1")
            let encodedData = try JSONEncoder().encode(viewInfoText)
            let decodedViewInfo = try JSONDecoder().decode(ViewInfo.self, from: encodedData)
            
            XCTAssertEqual(decodedViewInfo, viewInfoText)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func testComposedViewInfosEncodeDecodeConsistency() throws {
        let generatedViewInfoComponent = SampleViewInfoComponentHelper.sampleViewInfoComponent

        let encodedData = try! JSONEncoder().encode(generatedViewInfoComponent.viewInfo)
        let decodedViewInfo = try JSONDecoder().decode(ViewInfo .self, from: encodedData)
//        print(String(data: encodedData, encoding: .utf8)!)

        XCTAssertEqual(decodedViewInfo, generatedViewInfoComponent.viewInfo)
    }

    func testInvalidHexString() throws {
        // "FFF"
        let generatedViewInfoComponent = SampleViewInfoComponentHelper.sampleViewInfoComponent_InvalidHexString

        let encodedData = try! JSONEncoder().encode(generatedViewInfoComponent.viewInfo)
        let decodedViewInfo = try? JSONDecoder().decode(ViewInfo .self, from: encodedData)
        //        print(String(data: encodedData, encoding: .utf8)!)

        XCTAssertNil(decodedViewInfo)

        if let decodedViewInfo = decodedViewInfo {
            XCTAssertEqual(decodedViewInfo, generatedViewInfoComponent.viewInfo)
        }
    }

}
