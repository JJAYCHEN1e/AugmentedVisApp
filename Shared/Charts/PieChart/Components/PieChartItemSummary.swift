//
//  PieChartItemSummary.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/3.
//

import SwiftUI

struct PieChartItemSummary: View {
    @EnvironmentObject var viewModel: PieChartViewModel

    var body: some View {
        if viewModel.selectedIndex >= 0 {
            viewModel.additionalViewInfos[viewModel.selectedIndex]?.view
                .padding()
                .background(
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(.thickMaterial)
                        .cornerRadius(16)
                        .shadow(radius: 3)
                )
        } else {
            EmptyView()
        }
    }
}
