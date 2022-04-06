//
//  PieChartLegends.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/3.
//

import SwiftUI

struct PieChartLegends: View {
    @EnvironmentObject var viewModel: PieChartViewModel

    @State private var contentHeight: CGFloat = 0.0
    @State private var contentWidth: CGFloat = 0.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(viewModel.idConsistentItems) { element in
                    let index = viewModel.idConsistentItems.firstIndex(of: element)!
                    let isSelected = index == viewModel.selectedIndex

                    HStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: isSelected ? 5 : 3)
                            .frame(width: isSelected ? 16 : 10, height: isSelected ? 16 : 10)
                            .foregroundColor(viewModel.colors[index])
                        Text(viewModel.labels[index])
                            .font(.title3)
                            .fontWeight(isSelected ? .bold : .regular)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, isSelected ? 0 : 3)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            if viewModel.selectedIndex == index {
                                viewModel.selectedIndex = -1
                            } else {
                                viewModel.selectedIndex = index
                            }
                        }
                    }
                }
            }
            .padding()
            .overlay(GeometryReader { geo in
                executeAsync {
                    withAnimation(.spring()) {
                        contentHeight = geo.frame(in: .local).height
                    }
                }
            })
        }
        .background(
            Rectangle()
                .foregroundColor(.clear)
                .background(.thickMaterial)
                .cornerRadius(16)
                .shadow(radius: 3)
        )
        .frame(maxHeight: contentHeight)
    }
}
