//
//  ContentView.swift
//  Shared
//
//  Created by jjaychen on 2021/9/29.
//

import SVGView
import SwiftCSV
import SwiftUI

class SVGContent: ObservableObject {
    @Published var visInfo: VisInfo?

    static var shared = SVGContent()
}

struct SVGContentView: View {
    @ObservedObject var model: SVGContent
    var body: some View {
        ZStack {
            Color.clear
            if let visInfo = model.visInfo {
                Group {
                    SVGView(string: visInfo.outerRootSVG)
                    ZStack {
                        SVGView(string: visInfo.innerRootGroup)
                        Group {
                            Group {
                                ForEach(visInfo.dataComponents, id: \.self) { dataComponent in
                                    SVGView(string: dataComponent)
                                        .onTapGesture {
                                            print(dataComponent)
                                        }
                                }
                            }
                            if let xAxisGroup = visInfo.xAxisGroup {
                                SVGView(string: xAxisGroup)
                            }
                            if let yAxisGroup = visInfo.yAxisGroup {
                                SVGView(string: yAxisGroup)
                            }
                        }
                        .offset(x: visInfo.margin.left, y: visInfo.margin.top)
                    }
                }
                .background(Color.white)
            }
        }
    }
}

struct AppMainView: View {
    @ObservedObject var model = SVGContent.shared
    var body: some View {
        HSplitView {
            EditorPanelViewControllerRepresentable()
            SVGContentView(model: model)
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
