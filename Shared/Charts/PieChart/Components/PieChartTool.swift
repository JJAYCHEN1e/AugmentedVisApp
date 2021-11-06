//
//  PieChartTool.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/3.
//

import SwiftUI

struct PieChartTool: View {
    @EnvironmentObject var viewModel: PieChartViewModel
    private struct _ButtonStyle: ButtonStyle {
        private var color: Color

        init(color: Color) {
            self.color = color
        }

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .foregroundColor(configuration.isPressed ? Color.white.opacity(0.75) : Color.white)
                .background(configuration.isPressed ? color.opacity(0.75) : color)
                .cornerRadius(10)
        }
    }

    @State private var contentHeight: CGFloat = 0.0

    var body: some View {
        VStack(alignment: .trailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.itemGroups) { element in
                        let index = viewModel.itemGroups.firstIndex(of: element)!
                        let isSelected = viewModel.groupIndex == index
                        
                        HStack {
                            RoundedRectangle(cornerRadius: isSelected ? 5 : 3)
                                .frame(width: isSelected ? 14 : 10, height: isSelected ? 14 : 10)
                                .foregroundColor(.red)
                            Text(viewModel.itemGroups[index].title)
                                .font(.title3)
                                .fontWeight(isSelected ? .medium : .regular)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        .padding(.horizontal, isSelected ? 0 : 2)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                viewModel.groupIndex = index
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
            .animation(.spring(), value: viewModel.groupIndex)

            HStack {
                if viewModel.historyItemGroups.count > 0 {
                    Button {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            viewModel.showPreviousItemGroups()
                        }
                    } label: {
                        Text("返回上级")
                    }
                    .buttonStyle(_ButtonStyle(color: .orange))
                    .transition(.opacity)
                }

                if viewModel.selectedIndex != -1 && viewModel.itemDetailPieChartItemGroups[viewModel.selectedIndex].count > 0 {
                    Button {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            if viewModel.selectedIndex != -1 && viewModel.itemDetailPieChartItemGroups[viewModel.selectedIndex].count > 0 {
                                viewModel.showNewItemGroups(itemGroups: viewModel.itemDetailPieChartItemGroups[viewModel.selectedIndex])
                            }
                        }
                    } label: {
                        let index = viewModel.selectedIndex
                        Text("\(index < 0 ? "查看详情" : "查看 \(viewModel.labels[index]) 详情")")
                    }
                    .buttonStyle(_ButtonStyle(color: viewModel.selectedIndex != -1 ? viewModel.colors[viewModel.selectedIndex] : Color.clear))
                    .transition(.opacity)
                }
            }
        }
    }
}

