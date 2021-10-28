//
//  ContentView.swift
//  Shared
//
//  Created by jjaychen on 2021/9/29.
//

import SwiftCSV
import SwiftUI

struct AppMainView: View {
    let viewModel = LineChartContainerViewModel(dataSources: SampleDataHelper.catSevNumOrderedSeries)
    var body: some View {
        VStack {
            LineChart(viewModel: viewModel)

            Button {
                LineChart(viewModel: viewModel, animationDisabled: true).snapshotMock()
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
