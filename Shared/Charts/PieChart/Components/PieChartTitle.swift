//
//  PieChartTitle.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/3.
//

import SwiftUI

struct PieChartTitle: View {
    @EnvironmentObject var viewModel: PieChartViewModel

    var body: some View {
        VStack {
            Text(viewModel.title)
                .font(.title)
            if viewModel.subtitle != nil {
                Text(viewModel.subtitle!)
                    .font(.title3)
            }
        }
    }
}
