//
//  ContentView.swift
//  Shared
//
//  Created by jjaychen on 2021/9/29.
//

import SwiftCSV
import SwiftUI

struct AppMainView: View {

    var body: some View {
        VStack {
            LineChartContainerView(dataSources: SampleDataHelper.catSevNumOrderedSeries)

            Button {
                LineChartContainerView(dataSources: SampleDataHelper.catSevNumOrderedSeries, animationDisabled: true).snapshot()
            } label: {
                Text("Save")
            }
            .padding(.bottom)

        }
        #if os(macOS)
            .frame(minWidth: 500, minHeight: 250)
        #endif
    }
}
