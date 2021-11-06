//
//  PieChartItemSummary.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/3.
//

import SwiftUI

struct PieChartItemSummary: View {
    @EnvironmentObject var viewModel: PieChartViewModel

    @State private var contentHeight: CGFloat = 0.0

    var body: some View {
        ScrollView {
            if viewModel.selectedIndex >= 0, viewModel.additionalViewInfos[viewModel.selectedIndex] != nil {
                viewModel.additionalViewInfos[viewModel.selectedIndex]?.view
                    .padding()
                    .overlay(GeometryReader { geo in
                        executeAsync {
                            withAnimation(.spring()) {
                                contentHeight = geo.frame(in: .local).height
                            }
                        }
                    })
            }
        }
        .background(
            Rectangle()
                .foregroundColor(.clear)
                .background(.thickMaterial)
                .cornerRadius(16)
                .shadow(radius: 3)
        )
        .frame(maxHeight: contentHeight)
        .animation(nil, value: UUID()) // Since `.animation(:)` was deprecated, we should use a value that will change every time to make this modifier work all the time. So we choose `UUID()` as a trick.å
    }
}
