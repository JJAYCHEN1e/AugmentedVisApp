//
//  ContentView.swift
//  Shared
//
//  Created by jjaychen on 2021/9/29.
//

import SwiftUI
import SwiftCSV

struct AppMainView: View {
	
	private func readDataSource() -> ChartData<Int> {
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
	
    var body: some View {
		LineChartContainerView(dataSources: [
			readDataSource()
		])
#if os(macOS)
			.frame(minWidth: 500, minHeight: 250)
#endif
    }
}
