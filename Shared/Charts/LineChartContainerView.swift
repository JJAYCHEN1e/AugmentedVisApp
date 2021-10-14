//
//  LineChartContainerView.swift
//  AugmentedVisApp
//
//  Created by jjaychen on 2021/10/11.
//

import Combine
import OrderedCollections
import SwiftUI
#if os(macOS)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

struct ChartData<X: Hashable & Comparable>: Hashable {
    let data: [X: CGFloat]
    let keys: [X]
}

class LineChartContainerViewModel<X: Hashable & Comparable>: ObservableObject {
    var fixedSize: CGSize?

    @Published var percentage: CGFloat = .zero

    @Published var isValid = true

    @Published var dataSources: [ChartData<X>]

    private var _extentY: Extent<CGFloat>?

    /// Extent for input's value. Same as y-axis's value range.
    var extentY: Extent<CGFloat> {
        if let _extentY = _extentY {
            return _extentY
        } else {
            if let maxValue = dataSources
                .compactMap({ $0.data.max { $0.value < $1.value }})
                .map(\.value)
                .max(),
                let minValue = dataSources
                .compactMap({ $0.data.min { $0.value < $1.value }})
                .map(\.value)
                .min() {
                _extentY = Extent<CGFloat>(min: CGFloat(minValue), max: CGFloat(maxValue))
                return _extentY!
            } else {
                isValid = false
                _extentY = Extent<CGFloat>(min: 0, max: 0)
                return _extentY!
            }
        }
    }

    /// x-asix's value range. Constantly, `[0, 1]`.
    var extentX: Extent<CGFloat> {
        Extent<CGFloat>(min: 0, max: 1)
    }

    private var _dataScaleX: PointScale<X>?

    var dataScaleX: PointScale<X> {
        if let _dataScaleX = _dataScaleX {
            return _dataScaleX
        } else {
            var keys = OrderedSet<X>()
            dataSources.forEach { keys.append(contentsOf: $0.keys) }
            keys.sort()

            if keys.count < 2 {
                isValid = false
                _dataScaleX = PointScale(domain: [], range: [extentX.min, extentX.max])
                return _dataScaleX!
            }

            _dataScaleX = PointScale(domain: keys, range: [extentX.min, extentX.max])
            return _dataScaleX!
        }
    }

    private var _maxXLabelLength: CGFloat?
    private var maxXLabelLength: CGFloat? {
        if let _maxXLabelLength = _maxXLabelLength {
            return _maxXLabelLength
        } else {
            let maxLength = dataScaleX.domain.map { "\($0)".widthOfString(usingFont: axisLabelTraditionalFont) * 1.5 }.max()
            _maxXLabelLength = maxLength
            return maxLength
        }
    }

    /// Estimate the max count of x labels that can be displayed.
    var xLabelMaxCount: Int {
        if let maxLength = maxXLabelLength {
            let axisLength = xAxis.scale.range.last! - xAxis.scale.range.first!
            return Int(axisLength / maxLength)
        }
        return 0
    }

    var xLabels: [X] {
        let n = dataScaleX.domain.count
        let pointScale = PointScale(domain: OrderedSet(0 ..< xLabelMaxCount), range: [0, CGFloat(n - 1)]).scale()
        return (0 ..< xLabelMaxCount).map { dataScaleX.domain[Int(pointScale($0)!)] }
    }

    var size: CGSize!

    /// Ugly........
    var xAxisTick: Tick {
        Tick(extent: .init(min: extentX.min, max: extentX.max), count: 5)
    }

    /// `xAxis` and `yAixs`'s scale have already considered `edgeInset` and label area.
    var xAxis: Axis {
        Axis(direction: .x,
             scale: LinearScale(domain: [extentX.min, extentX.max], range: [axisLeftMarginRefinedValue, size.width - axisRightMarginRefinedValue]),
             tick: xAxisTick,
             gridCount: 10)
    }

    /// `xAxis` and `yAixs`'s scale have already considered `edgeInset` and label area.
    var yAxis: Axis {
        Axis(direction: .y,
             scale: LinearScale(domain: [extentY.min, extentY.max], range: [size.height - edgeInset.bottom - xAxisLabelMaxHeight - labelMargin, edgeInset.top]),
             tickCount: 5,
             gridCount: 10)
    }

    #if os(macOS)
        /// Whole chart's edge inset.
        let edgeInset = EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16)
    #elseif os(iOS)
        /// Whole chart's edge inset.
        let edgeInset = EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8)
    #endif

    /// 坐标轴距离左边界的 margin
    @Published var axisLeftMarginRefinedValue: CGFloat = 0.0

    /// 坐标轴距离右边界的 margin
    @Published var axisRightMarginRefinedValue: CGFloat = 0.0

    let xAxisLabelMaxHeight: CGFloat = 17
    let labelMargin: CGFloat = 8.0

    // They should be identical
    let axisLabelFont = Font.system(size: 14).bold().monospacedDigit()

    #if os(macOS)
        let axisLabelTraditionalFont = NSFont(descriptor: NSFont.systemFont(ofSize: 14, weight: .bold)
            .fontDescriptor
            .addingAttributes([.featureSettings: [[
                NSFontDescriptor.FeatureKey.selectorIdentifier: kMonospacedNumbersSelector,
                NSFontDescriptor.FeatureKey.typeIdentifier: kNumberSpacingType
            ]]]), size: 0)!
    #elseif os(iOS)
        let axisLabelTraditionalFont = UIFont(descriptor: UIFont.systemFont(ofSize: 14, weight: .bold)
            .fontDescriptor
            .addingAttributes([.featureSettings: [[
                UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector
            ]]]), size: 0)
    #endif

    let axisLineWidth: CGFloat = 2.0
    let tickMarkHeight: CGFloat = 8.0
    let originalPointRidius: CGFloat = 5.0

    private var subscribers: Set<AnyCancellable> = []

    init(dataSources: [ChartData<X>] = [], fixedSize: CGSize? = nil) {
        self.dataSources = dataSources
        self.fixedSize = fixedSize

        let dataSourcesChangeSubscription = dataSources.publisher.sink { _ in
            self._dataScaleX = nil
            self._extentY = nil
            self._maxXLabelLength = nil

            self.percentage = 0.0
            withAnimation(.easeOut(duration: 10.0)) {
                self.percentage = 1.0
            }
        }
        subscribers.insert(dataSourcesChangeSubscription)
    }

    func refineMarginValue() {
        let xTick = xAxis.tick
        let yTick = yAxis.tick
        let scaleFunctionX = xAxis.scaleFunction

        // Refine Y
        let refinedY1 = scaleFunctionX(xTick.start) - String(format: "%.2f", xTick.start).widthOfString(usingFont: axisLabelTraditionalFont) / 2 // X 轴最左侧标签
        let refinedY2 = scaleFunctionX(0) - labelMargin - String(format: "%.2f", yTick.start).widthOfString(usingFont: axisLabelTraditionalFont) // Y 轴最下方标签
        let refinedY3 = scaleFunctionX(0) - labelMargin - String(format: "%.2f", yTick.stop).widthOfString(usingFont: axisLabelTraditionalFont) // Y 轴最上方标签
        let refinedY4 = scaleFunctionX(xAxis.scale.domainExtent.min) // X 轴左侧

        let refinedY = axisLeftMarginRefinedValue - min(refinedY1, refinedY2, refinedY3, refinedY4) + edgeInset.leading

        if axisLeftMarginRefinedValue != refinedY {
            axisLeftMarginRefinedValue = refinedY
        }

        // Refine X
        let refinedX1 = size.width - scaleFunctionX(xAxis.scale.domainExtent.max) // X 轴右侧
        let refinedX2 = size.width - (scaleFunctionX(xTick.stop) + String(format: "%.2f", xTick.stop).widthOfString(usingFont: axisLabelTraditionalFont) / 2) // X 轴右侧标签
        let refinedX3 = size.width - (scaleFunctionX(0) + tickMarkHeight) // Y 轴 Tick Mark

        let refinedX = axisRightMarginRefinedValue - min(refinedX1, refinedX2, refinedX3) + edgeInset.trailing

        if axisRightMarginRefinedValue != refinedX {
            axisRightMarginRefinedValue = refinedX
        }
    }

    func lineColor(dataSource: ChartData<X>) -> Color {
        // category10 colors from d3 - https://github.com/mbostock/d3/wiki/Ordinal-Scales
        let colors: [Color] = [
            Color(red: 0.121569, green: 0.466667, blue: 0.705882, opacity: 1),
            Color(red: 1, green: 0.498039, blue: 0.054902, opacity: 1),
            Color(red: 0.172549, green: 0.627451, blue: 0.172549, opacity: 1),
            Color(red: 0.839216, green: 0.152941, blue: 0.156863, opacity: 1),
            Color(red: 0.580392, green: 0.403922, blue: 0.741176, opacity: 1),
            Color(red: 0.54902, green: 0.337255, blue: 0.294118, opacity: 1),
            Color(red: 0.890196, green: 0.466667, blue: 0.760784, opacity: 1),
            Color(red: 0.498039, green: 0.498039, blue: 0.498039, opacity: 1),
            Color(red: 0.737255, green: 0.741176, blue: 0.133333, opacity: 1),
            Color(red: 0.0901961, green: 0.745098, blue: 0.811765, opacity: 1)
        ]

        if let i = dataSources.firstIndex(of: dataSource) {
            return colors[i % colors.count]
        } else {
            return colors[0]
        }
    }
}

struct LineChartContainerView<X: Hashable & Comparable>: View {
    @ObservedObject private var viewModel = LineChartContainerViewModel<X>()

    init(dataSources: [ChartData<X>] = [], fixedSize: CGSize? = nil) {
        viewModel.dataSources = dataSources
        viewModel.fixedSize = fixedSize
    }

    private func setUp(width _: CGFloat, height _: CGFloat) {}

    var body: some View {
        if viewModel.isValid {
            GeometryReader { geo in
                execute {
                    viewModel.size = geo.size
                    viewModel.refineMarginValue()
                }

                ZStack {
                    // Horizontal Grid Lines
                    Canvas { cxt, _ in
                        let path = Path {
                            let scaleFunctionY = viewModel.yAxis.scaleFunction
                            let gridStepLengthY = viewModel.yAxis.gridStepLength

                            let scaleFunctionX = viewModel.xAxis.scaleFunction

                            let domainMaxY = viewModel.yAxis.scale.domainExtent.max
                            let domainMinY = viewModel.yAxis.scale.domainExtent.min
                            let domainMaxX = viewModel.xAxis.scale.domainExtent.max
                            let domainMinX = viewModel.xAxis.scale.domainExtent.min

                            var index = 1
                            while true {
                                let _y = CGFloat(index) * gridStepLengthY
                                if _y > domainMaxY, -_y < domainMinY {
                                    break
                                }

                                if !(_y > domainMaxY) {
                                    let y = scaleFunctionY(_y)
                                    $0.move(to: .init(x: scaleFunctionX(domainMinX), y: y))
                                    $0.addLine(to: .init(x: scaleFunctionX(domainMaxX), y: y))
                                }

                                if !(-_y < domainMinY) {
                                    let y = scaleFunctionY(-_y)
                                    $0.move(to: .init(x: scaleFunctionX(domainMinX), y: y))
                                    $0.addLine(to: .init(x: scaleFunctionX(domainMaxX), y: y))
                                }

                                index += 1
                            }
                        }
                        cxt.stroke(path, with: .color(.gray.opacity(0.3)), lineWidth: 1)
                    }

                    // Vertical Grid Lines
                    Canvas { cxt, _ in
                        let path = Path {
                            let scaleFunctionX = viewModel.xAxis.scaleFunction
                            let gridStepLengthX = viewModel.xAxis.gridStepLength

                            let scaleFunctionY = viewModel.yAxis.scaleFunction

                            let domainMaxY = viewModel.yAxis.scale.domainExtent.max
                            let domainMinY = viewModel.yAxis.scale.domainExtent.min
                            let domainMaxX = viewModel.xAxis.scale.domainExtent.max
                            let domainMinX = viewModel.xAxis.scale.domainExtent.min

                            var index = 1
                            while true {
                                let _x = CGFloat(index) * gridStepLengthX
                                if _x > domainMaxX, -_x < domainMinX {
                                    break
                                }

                                if !(_x > domainMaxY) {
                                    let x = scaleFunctionX(_x)
                                    $0.move(to: .init(x: x, y: scaleFunctionY(domainMinY)))
                                    $0.addLine(to: .init(x: x, y: scaleFunctionY(domainMaxY)))
                                }

                                if !(-_x < domainMinY) {
                                    let x = scaleFunctionX(-_x)
                                    $0.move(to: .init(x: x, y: scaleFunctionY(domainMinY)))
                                    $0.addLine(to: .init(x: x, y: scaleFunctionY(domainMaxY)))
                                }

                                index += 1
                            }
                        }
                        cxt.stroke(path, with: .color(.gray.opacity(0.3)), lineWidth: 1)
                    }

                    // yAxis Label
                    Canvas { cxt, _ in
                        let tick = viewModel.yAxis.tick
                        let scaleFunctionY = viewModel.yAxis.scaleFunction
                        let scaleFunctionX = viewModel.xAxis.scaleFunction

                        for i in 0 ... viewModel.yAxis.tickCount {
                            let y = tick.start + CGFloat(i) * tick.step
                            if y == 0.0, viewModel.extentY.min < 0 {
                                cxt.draw(
                                    Text(String(format: "%.2f", y))
                                        .font(.system(size: 14).bold()),
                                    at: .init(x: scaleFunctionX(0) - viewModel.labelMargin, y: scaleFunctionY(y) - viewModel.labelMargin),
                                    anchor: .bottomTrailing
                                )
                            } else {
                                cxt.draw(
                                    Text(String(format: "%.2f", y))
                                        .font(.system(size: 14).bold()),
                                    at: .init(x: scaleFunctionX(0) - viewModel.labelMargin, y: scaleFunctionY(y)),
                                    anchor: .trailing
                                )

                                // Tick Mark
                                let path = Path {
                                    $0.move(to: .init(x: scaleFunctionX(0), y: scaleFunctionY(y)))
                                    $0.addLine(to: .init(x: scaleFunctionX(0) + viewModel.tickMarkHeight, y: scaleFunctionY(y)))
                                }
                                cxt.stroke(path, with: .color(.primary), lineWidth: viewModel.axisLineWidth)
                            }
                        }
                    }

                    // xAxis Label(Original Number)
                    Canvas { cxt, _ in
                        let tick = viewModel.xAxis.tick
                        let scaleFunctionX = viewModel.xAxis.scaleFunction
                        let scaleFunctionY = viewModel.yAxis.scaleFunction
                        for i in 0 ... viewModel.xAxis.tickCount {
                            let x = tick.start + CGFloat(i) * tick.step
                            if x == 0.0, viewModel.extentX.min < 0 {
                                cxt.draw(
                                    Text(String(format: "%.2f", x))
                                        .font(viewModel.axisLabelFont),
                                    at: .init(x: scaleFunctionX(x) + viewModel.labelMargin, y: scaleFunctionY(0) + viewModel.labelMargin),
                                    anchor: .topLeading
                                )
                            } else {
                                cxt.draw(
                                    Text(String(format: "%.2f", x))
                                        .font(viewModel.axisLabelFont),
                                    at: .init(x: scaleFunctionX(x), y: scaleFunctionY(0) + viewModel.labelMargin),
                                    anchor: .top
                                )

                                // Tick Mark
                                let path = Path {
                                    $0.move(to: .init(x: scaleFunctionX(x), y: scaleFunctionY(0)))
                                    $0.addLine(to: .init(x: scaleFunctionX(x), y: scaleFunctionY(0) + viewModel.tickMarkHeight))
                                }
                                cxt.stroke(path, with: .color(Color(Asset.dynamicBlack.color)), lineWidth: viewModel.axisLineWidth)
                            }
                        }
                    }
                    .opacity(0)

                    // xAxis Label
                    Canvas { cxt, _ in
                        for label in viewModel.xLabels {
                            let scaleFunctionX = viewModel.xAxis.scaleFunction
                            let scaleFunctionY = viewModel.yAxis.scaleFunction
                            let dataPointScale = viewModel.dataScaleX.scale()
                            if let _x = dataPointScale(label) {
                                let x = scaleFunctionX(_x)
                                let str = "\(label)"
                                cxt.draw(
                                    Text(str)
                                        .font(viewModel.axisLabelFont),
                                    at: .init(x: x, y: scaleFunctionY(0) + viewModel.labelMargin),
                                    anchor: .top
                                )

                                // Tick Mark
                                let path = Path {
                                    $0.move(to: .init(x: x, y: scaleFunctionY(0)))
                                    $0.addLine(to: .init(x: x, y: scaleFunctionY(0) - viewModel.tickMarkHeight))
                                }
                                cxt.stroke(path, with: .color(Color(Asset.dynamicBlack.color)), lineWidth: viewModel.axisLineWidth)
                            }
                        }
                    }

                    // yAxis
                    Canvas { cxt, _ in
                        let path = Path {
                            let scaleFunctionX = viewModel.xAxis.scaleFunction
                            let scaleFunctionY = viewModel.yAxis.scaleFunction

                            $0.move(to: .init(x: scaleFunctionX(0), y: scaleFunctionY(viewModel.yAxis.scale.domainExtent.min)))
                            $0.addLine(to: .init(x: scaleFunctionX(0), y: scaleFunctionY(viewModel.yAxis.scale.domainExtent.max)))
                        }
                        cxt.stroke(path, with: .color(Color(Asset.dynamicBlack.color)), lineWidth: viewModel.axisLineWidth)
                    }

                    // xAxis
                    Canvas { cxt, _ in
                        let path = Path {
                            let scaleFunctionY = viewModel.yAxis.scaleFunction
                            let scaleFunctionX = viewModel.xAxis.scaleFunction

                            $0.move(to: .init(x: scaleFunctionX(viewModel.xAxis.scale.domainExtent.min), y: scaleFunctionY(0)))
                            $0.addLine(to: .init(x: scaleFunctionX(viewModel.xAxis.scale.domainExtent.max), y: scaleFunctionY(0)))
                        }
                        cxt.stroke(path, with: .color(Color(Asset.dynamicBlack.color)), lineWidth: viewModel.axisLineWidth)
                    }

                    // Line
                    ForEach(viewModel.dataSources, id: \.self) { dataSource in
                        Path { path in
                            let calXY = { (key: X) -> (CGFloat, CGFloat) in
                                let _x = viewModel.dataScaleX.scale()(key)!
                                let x = viewModel.xAxis.scale.scale()(_x)
                                let _y = CGFloat(dataSource.data[key]!)
                                let y = viewModel.yAxis.scale.scale()(_y)

                                return (x, y)
                            }

                            let key = dataSource.keys.first!
                            let (x, y) = calXY(key)
                            path.move(to: .init(x: x, y: y))

                            for key in dataSource.keys.dropFirst() {
                                let (x, y) = calXY(key)
                                path.addLine(to: .init(x: x, y: y))
                            }
                        }
                        .trim(from: 0, to: viewModel.percentage)
                        .stroke(lineWidth: 4)
                        .onTapGesture {
                            print("Tapped")
                        }
                        .foregroundColor(viewModel.lineColor(dataSource: dataSource))
                        .onAppear {
                            withAnimation(.easeOut(duration: 10.0)) {
                                viewModel.percentage = 1.0
                            }
                        }

                        Path { path in
                            let calXY = { (key: X) -> (CGFloat, CGFloat) in
                                let _x = viewModel.dataScaleX.scale()(key)!
                                let x = viewModel.xAxis.scale.scale()(_x)
                                let _y = CGFloat(dataSource.data[key]!)
                                let y = viewModel.yAxis.scale.scale()(_y)

                                return (x, y)
                            }

                            let (xStart, _) = calXY(dataSource.keys.first!)
                            path.move(to: .init(x: xStart, y: viewModel.yAxis.scale.scale()(0)))

                            for key in dataSource.keys {
                                let (x, y) = calXY(key)
                                path.addLine(to: .init(x: x, y: y))
                            }

                            let (xEnd, _) = calXY(dataSource.keys.last!)
                            path.addLine(to: .init(x: xEnd, y: viewModel.yAxis.scale.scale()(0)))
                            path.addLine(to: .init(x: xStart, y: viewModel.yAxis.scale.scale()(0)))
                        }
                        .fill(viewModel.lineColor(dataSource: dataSource).opacity(0.2))
                        .onTapGesture {
                            print(viewModel.lineColor(dataSource: dataSource))
                        }
                    }

                    // Original Point
                    Canvas { cxt, _ in
                        let scaleFunctionY = viewModel.yAxis.scaleFunction
                        let scaleFunctionX = viewModel.xAxis.scaleFunction
                        let r = viewModel.originalPointRidius
                        let point = Path(ellipseIn: .init(x: scaleFunctionX(0) - r, y: scaleFunctionY(0) - r, width: 2 * r, height: 2 * r))
                        cxt.fill(point, with: .color(Color(Asset.dynamicBlack.color)))
                    }
                    .allowsHitTesting(false)
                }
                .simultaneousGesture(
                    TapGesture().onEnded {
                        print("Tapped Globally.")
                    }
                )
            }
        }
    }
}
