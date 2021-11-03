//
//  PieChart.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/10/31.
//

import SwiftUI

struct PieChart: View {
    @EnvironmentObject var viewModel: PieChartViewModel

    var body: some View {
        HStack(alignment: .top) {
            VStack(spacing: 24) {
                PieChartTitle()
                GeometryReader { geo in
                    PieChartMain(geo: geo)
                }
            }
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 24) {
                    PieChartLegends()
                    PieChartItemSummary()
                    Spacer()
                    PieChartTool()
                }
            }
            .frame(maxWidth: 250)
        }
        .padding()
    }
}

struct PieChart_Previews: PreviewProvider {
    static var previews: some View {

        let viewModel = PieChartViewModel(itemGroups: [
            SamplePieChartDataHelper.SamplePieChartDataTGCategoryLocItemGroup(),
            SamplePieChartDataHelper.SamplePieChartDataTGCategoryFileCountItemGroup(),
            SamplePieChartDataHelper.SamlePieChartDataTGCategorySubmoduleItemGroup()
        ],
                                          defaultItemGroupIndex: 0,
                                          borderColor: .white)

        PieChart()
            .environmentObject(viewModel)
    }
}
