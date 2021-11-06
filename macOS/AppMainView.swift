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
//        let viewModel = LineChartContainerViewModel(dataSources: SampleDataHelper.catSevNumOrderedSeries)
//        VStack {
//            LineChart(viewModel: viewModel)
//
//            Button {
//                LineChart(viewModel: viewModel, animationDisabled: true).snapshotMock()
//            } label: {
//                Text("Save")
//            }
//            .padding(.bottom)
//
//        }
//        #if os(macOS)
//            .frame(minWidth: 500, minHeight: 250)
//        #endif

        VStack {
            PieChart_Previews.previews

//            Button {
//                PieChart_Previews.previews.snapshotMock()
//            } label: {
//                Text("Save")
//            }
//            .padding(.bottom)

        }
//        #if os(macOS)
//        .frame(minWidth: 1280, minHeight: 720)
//        #endif
    }
}
