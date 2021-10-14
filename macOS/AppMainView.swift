//
//  ContentView.swift
//  Shared
//
//  Created by jjaychen on 2021/9/29.
//

import SwiftUI
import SwiftCSV

struct AppMainView: View {
	
    var body: some View {
		LineChartContainerView(dataSources: SampleDataHelper.catSevNumOrderedSeries)
#if os(macOS)
			.frame(minWidth: 500, minHeight: 250)
#endif
    }
}
