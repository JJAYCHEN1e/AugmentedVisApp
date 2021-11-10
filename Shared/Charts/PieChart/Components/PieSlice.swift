//
//  PieSlice.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/11/3.
//

import SwiftUI

struct PieSliceText: View {
    let title: String
    let description: String

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.body)
        }
    }
}

struct PieSliceShape: Shape {
    var startAngle: Double
    var endAngle: Double

    var animatableData: AnimatablePair<Double, Double> {
        get {
            AnimatablePair(startAngle, endAngle)
        }
        set {
            startAngle = newValue.first
            endAngle = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2
        let alpha = CGFloat(startAngle)

        let center = CGPoint(
            x: rect.midX,
            y: rect.midY
        )

        path.move(to: center)

        path.addLine(
            to: CGPoint(
                x: center.x + cos(alpha) * radius,
                y: center.y + sin(alpha) * radius
            )
        )

        path.addArc(
            center: center,
            radius: radius,
            startAngle: Angle(radians: startAngle),
            endAngle: Angle(radians: endAngle),
            clockwise: false
        )

        path.closeSubpath()

        return path
    }
}

struct Pie: View {
    @EnvironmentObject var viewModel: PieChartViewModel
    @State var index: Int
    @State var geo: GeometryProxy

    var body: some View {
        let dumb = index >= viewModel.items.count
        let startAngle = !dumb ? self.startAngle : (viewModel.sliceOffset + 2 * .pi - 0.01)
        let endAngle = !dumb ? self.endAngle : (viewModel.sliceOffset + 2 * .pi)

        let isTouched = index == viewModel.selectedIndex
        let pieSliceShape = PieSliceShape(startAngle: startAngle, endAngle: endAngle)
        let strokeLineWidth = endAngle - startAngle < .pi / 90 ? 0.1 : endAngle - startAngle < .pi / 180 ? 0 : 1

        pieSliceShape
            .fill(viewModel.colors[index % viewModel.colors.count])
            .overlay(pieSliceShape.stroke(viewModel.borderColor, lineWidth: strokeLineWidth))
            .opacity(dumb ? 0.0 : 1.0)
            .scaleEffect(isTouched ? 1.03 : 1)
            .zIndex(viewModel.selectedIndex == index ? 2 : 0)
            .onTapGesture {
                withAnimation(.spring()) {
                    if viewModel.selectedIndex == index {
                        viewModel.selectedIndex = -1
                    } else {
                        viewModel.selectedIndex = index
                    }
                }
            }

        if index < viewModel.items.count {
            PieSliceText(
                title: "\(viewModel.labels[index])",
                description: String(format: viewModel.dataDescription ?? "%.2f", viewModel.data[index]).appending(viewModel.dataDescriptionSuffix ?? "")
            )
                .padding(.all, 5)
                .background(
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(.ultraThickMaterial)
                        .shadow(radius: 3)
                        .cornerRadius(8)
                )
                .offset(textOffset)
                .scaleEffect(isTouched ? 1.03 : 1)
                .opacity(viewModel.selectedIndex == index || viewModel.showLabelEnabled && endAngle - startAngle > .pi / 15 ? 1.0 : 0.0)
                .zIndex(viewModel.selectedIndex == index ? 3 : 1)
                .allowsHitTesting(false)
        }
    }

    var startAngle: Double {
        switch index {
        case 0:
            return viewModel.sliceOffset
        default:
            let ratio: Double = viewModel.data[..<index].reduce(0.0, +) / viewModel.data.reduce(0.0, +)
            return viewModel.sliceOffset + 2 * .pi * ratio
        }
    }

    var endAngle: Double {
        switch index {
        case viewModel.data.count - 1:
            return viewModel.sliceOffset + 2 * .pi
        default:
            let ratio: Double = viewModel.data[..<(index + 1)].reduce(0.0, +) / viewModel.data.reduce(0.0, +)
            return viewModel.sliceOffset + 2 * .pi * ratio
        }
    }

    var textOffset: CGSize {
        let denominator: CGFloat = endAngle - startAngle > .pi / 15 ? 4.0 : 3.0
        let radius = min(geo.size.width, geo.size.height) / denominator
        let dataRatio = (2 * viewModel.data[..<index].reduce(0, +) + viewModel.data[index]) / (2 * viewModel.data.reduce(0, +))
        let angle = CGFloat(viewModel.sliceOffset + 2 * .pi * dataRatio)
        return CGSize(width: radius * cos(angle), height: radius * sin(angle))
    }
}

struct PieChartMain: View {
    @EnvironmentObject var viewModel: PieChartViewModel

    private var geo: GeometryProxy

    init(geo: GeometryProxy) {
        self.geo = geo
    }

    var body: some View {
        ZStack(alignment: .center) {
            ForEach(viewModel.idConsistentDumbItems) { element in
                let index = viewModel.idConsistentDumbItems.firstIndex(of: element)!

                if index < viewModel.idConsistentDumbItems.count {
                    Pie(index: index, geo: geo)
                }
            }
        }
    }
}
