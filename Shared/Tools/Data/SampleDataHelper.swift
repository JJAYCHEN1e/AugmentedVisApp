//
//  SampleDataHelper.swift
//  SampleDataHelper
//
//  Created by jjaychen on 2021/10/13.
//

import Foundation
import SwiftCSV

class SampleDataHelper {
	static func readLineChartSampleDataSourceCatSevNumOrdered() -> ChartData<Int> {
		let resource = try! CSV(
			name: "data",
			extension: "csv",
			bundle: .main,
			delimiter: ",",
			encoding: .utf8)!
		
		var aggregatedSumDic: [Int : CGFloat] = [:]
		
		resource.namedRows.forEach { row in
			if let _year = row["year"], let year = Int(_year), let _n = row["n"], let n = Int(_n) {
				aggregatedSumDic[year] = aggregatedSumDic[year, default: 0] + CGFloat(n)
			} else {
				fatalError("Corrupted Data!")
			}
		}
		
		let sortedKeys = aggregatedSumDic.keys.sorted()
		
		return ChartData(data: aggregatedSumDic, keys: sortedKeys)
	}
}
