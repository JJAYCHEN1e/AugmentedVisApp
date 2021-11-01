//
//  BarChart.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/10/31.
//

import SwiftUI

struct BarChartGrid: Shape {
    let divisions: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stepSize = rect.height / CGFloat(divisions)

        (1 ... divisions).forEach { step in
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY - stepSize * CGFloat(step)))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - stepSize * CGFloat(step)))
        }

        return path
    }
}

struct BarPath: Shape {
    let data: Double
    let max: Double
    let min: Double

    func path(in rect: CGRect) -> Path {
        guard min != max else {
            return Path()
        }

        let height = CGFloat((data - min) / (max - min)) * rect.height
        let bar = CGRect(x: rect.minX, y: rect.minY + rect.height - height, width: rect.width, height: height)

        return RoundedRectangle(cornerRadius: 5).path(in: bar)
    }
}

struct BarStack: View {
    @Binding var data: [Double]
    @Binding var labels: [String]
    let accentColor: Color
    let gridColor: Color
    let showGrid: Bool
    let min: Double
    let max: Double
    let spacing: CGFloat

    var body: some View {
        HStack(alignment: .bottom, spacing: spacing) {
            ForEach(0 ..< data.count) { index in
                LinearGradient(
                    gradient: .init(
                        stops: [
                            .init(color: Color.secondary.opacity(0.6), location: 0),
                            .init(color: accentColor.opacity(0.6), location: 0.4),
                            .init(color: accentColor, location: 1)
                        ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                    .clipShape(BarPath(data: data[index], max: max, min: min))
            }
        }
        .shadow(color: .black, radius: 5, x: 1, y: 1)
        .padding(.horizontal, spacing)
    }
}

struct BarChartAxes: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

        return path
    }
}

struct LabelStack: View {
    @Binding var labels: [String]
    let spacing: CGFloat

    var body: some View {
        HStack(alignment: .center, spacing: spacing) {
            ForEach(labels, id: \.self) { label in
                Text(label)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, spacing)
    }
}

struct BarChart: View {
    @Binding var data: [Double]
    @Binding var labels: [String]
    let accentColor: Color
    let axisColor: Color
    let showGrid: Bool
    let gridColor: Color
    let spacing: CGFloat

    private var minimum: Double {
        0
        //(data.min() ?? 0) * 0.95
    }
    private var maximum: Double { (data.max() ?? 1) * 1.05 }

    var body: some View {
        VStack {
            ZStack {
                if showGrid {
                    BarChartGrid(divisions: 10)
                        .stroke(gridColor.opacity(0.2), lineWidth: 0.5)
                }

                BarStack(data: $data,
                         labels: $labels,
                         accentColor: accentColor,
                         gridColor: gridColor,
                         showGrid: showGrid,
                         min: minimum,
                         max: maximum,
                         spacing: spacing)

                BarChartAxes()
                    .stroke(axisColor, lineWidth: 2)
            }

            LabelStack(labels: $labels, spacing: spacing)
        }
        .padding([.horizontal, .top], 20)
    }
}

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        BarChart(data: .constant([100, 200, 150, 80, 80, 120, 1200]), labels: .constant(["a", "b", "c", "d", "e", "f", "g"]), accentColor: .blue, axisColor: .gray, showGrid: true, gridColor: .white, spacing: 10)
    }
}
