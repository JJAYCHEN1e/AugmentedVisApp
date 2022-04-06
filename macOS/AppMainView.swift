//
//  ContentView.swift
//  Shared
//
//  Created by jjaychen on 2021/9/29.
//

import SVGView
import SwiftCSV
import SwiftUI

struct AppMainView: View {
    var body: some View {
        HSplitView {
            EditorPanelViewControllerRepresentable()
            ZStack {
                Color.clear
                Text("123")
            }
        }
    }
}

// struct AppMainView: View {
//    var body: some View {
//        let qrCodeSize = ImageGenerateHelper.qrCodeSize
//        let graphWidth = ImageGenerateHelper.graphWidth
//        let graphHeight = ImageGenerateHelper.graphHeight
//        let padding = ImageGenerateHelper.padding
//
//        let chartView =
//            VStack {
//                PieChart_Previews.previews
//            }
//            .preferredColorScheme(.light)
//
//        PreviewContainerViewControllerRepresentable(chartView: chartView)
//            .frame(width: graphWidth + padding + qrCodeSize, height: graphHeight)
//
////        let viewModel = LineChartContainerViewModel(dataSources: SampleDataHelper.catSevNumOrderedSeries)
////        VStack {
////            LineChart(viewModel: viewModel)
////
////            Button {
////                LineChart(viewModel: viewModel, animationDisabled: true).snapshotMock()
////            } label: {
////                Text("Save")
////            }
////            .padding(.bottom)
////
////        }
////        #if os(macOS)
////            .frame(minWidth: 500, minHeight: 250)
////        #endif
//    }
// }
