//
//  PieChart.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/10/31.
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

struct PieSlice: Shape {
    let startAngle: Double
    let endAngle: Double

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

struct PieChart: View {
    @Binding var data: [Double]
    @Binding var labels: [String]

    private let colors: [Color]
    private let borderColor: Color
    private let sliceOffset: Double = -.pi / 2

    init(data: Binding<[Double]>, labels: Binding<[String]>, colors: [Color], borderColor: Color) {
        self._data = data
        self._labels = labels
        self.colors = colors
        self.borderColor = borderColor
    }

    @State private var selectedIndex: Int = -1

    // Deprecated
    @State private var touchLocation: CGPoint = .zero

    // Deprecated
    func isTouched(frame: CGRect, startAngle: Double, endAngle: Double) -> Bool {
        let radius = min(frame.width, frame.height) / 2
        let center = CGPoint(x: frame.midX, y: frame.midY)
        let offset = CGPoint(x: touchLocation.x - center.x, y: touchLocation.y - center.y)
        guard offset.x * offset.x + offset.y * offset.y <= radius * radius else {
            return false
        }

        var angle = Double(atan2(offset.y, offset.x))
        if angle < -.pi / 2 {
            angle += .pi * 2
        }

        if angle >= startAngle && angle <= endAngle {
            return true
        }

        return false
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                ForEach(0 ..< data.count) { index in
                    let startAngle = startAngle(for: index)
                    let endAngle = endAngle(for: index)
                    let pieSlice = PieSlice(startAngle: startAngle, endAngle: endAngle)
                    let isTouched = index == self.selectedIndex

                    pieSlice
                        .fill(colors[index % colors.count])
                        .overlay(pieSlice.stroke(borderColor, lineWidth: 1.5))
                        .scaleEffect(isTouched ? 1.03 : 1)
                        .animation(Animation.spring(), value: isTouched)
                        .onTapGesture {
                            if self.selectedIndex == index {
                                self.selectedIndex = -1
                            } else {
                                self.selectedIndex = index
                            }
                        }

                    PieSliceText(
                        title: "\(labels[index])",
                        description: String(format: "%.2f", data[index])
                    )
                        .offset(textOffset(for: index, in: geo.size))
                        .zIndex(1)
                }
            }
        }
        .padding()
        .background(Rectangle().fill().opacity(0.001))
    }

    private func startAngle(for index: Int) -> Double {
        switch index {
        case 0:
            return sliceOffset
        default:
            let ratio: Double = data[..<index].reduce(0.0, +) / data.reduce(0.0, +)
            return sliceOffset + 2 * .pi * ratio
        }
    }

    private func endAngle(for index: Int) -> Double {
        switch index {
        case data.count - 1:
            return sliceOffset + 2 * .pi
        default:
            let ratio: Double = data[..<(index + 1)].reduce(0.0, +) / data.reduce(0.0, +)
            return sliceOffset + 2 * .pi * ratio
        }
    }

    private func textOffset(for index: Int, in size: CGSize) -> CGSize {
        let radius = min(size.width, size.height) / 3
        let dataRatio = (2 * data[..<index].reduce(0, +) + data[index]) / (2 * data.reduce(0, +))
        let angle = CGFloat(sliceOffset + 2 * .pi * dataRatio)
        return CGSize(width: radius * cos(angle), height: radius * sin(angle))
    }
}

struct PieChart_Previews: PreviewProvider {
    static var previews: some View {
        PieChart(data: .constant([100, 200, 300, 400]), labels: .constant(["1", "2", "3", "4"]), colors: [.red, .blue, .cyan, .pink], borderColor: .white)
    }
}
