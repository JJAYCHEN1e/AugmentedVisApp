//
//  LineChartContainerView.swift
//  AugmentedVisApp
//
//  Created by jjaychen on 2021/10/11.
//

import SwiftUI

// swiftlint:disable type_body_length
struct LineChartContainerView<X: Hashable & Comparable>: View {
    let animationDisabled: Bool

    @ObservedObject private var viewModel = LineChartContainerViewModel<X>()

    @State private var pointerPosition: CGPoint?

    init(dataSources: [ChartData<X>] = [], fixedSize: CGSize? = nil, animationDisabled: Bool = false) {
        self.animationDisabled = animationDisabled
        viewModel.dataSources = dataSources
        viewModel.fixedSize = fixedSize
    }

    private func setUp(width _: CGFloat, height _: CGFloat) {}

    var body: some View {
        if viewModel.isValid {
            GeometryReader { geo in
                execute {
                    if viewModel.size != geo.size {
                        viewModel.size = geo.size
                        DispatchQueue.main.async {
                            pointerPosition = nil
                        }
                    }
                    viewModel.refineMarginValue()
                }

                ZStack {
                    #if os(macOS)
                    // Horizontal Grid Lines
                    Canvas { ctx, _ in
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
                        ctx.stroke(path, with: .color(.gray.opacity(0.3)), lineWidth: 1)
                    }

                    // Vertical Grid Lines
                    Canvas { ctx, _ in
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
                        ctx.stroke(path, with: .color(.gray.opacity(0.3)), lineWidth: 1)
                    }

                    // yAxis Label
                    Canvas { ctx, _ in
                        let tick = viewModel.yAxis.tick
                        let scaleFunctionY = viewModel.yAxis.scaleFunction
                        let scaleFunctionX = viewModel.xAxis.scaleFunction

                        for i in 0 ... viewModel.yAxis.tickCount {
                            let y = tick.start + CGFloat(i) * tick.step
                            if y == 0.0, viewModel.extentY.min < 0 {
                                ctx.draw(
                                    Text(String(format: "%.2f", y))
                                        .font(.system(size: 14).bold()),
                                    at: .init(x: scaleFunctionX(0) - viewModel.labelMargin, y: scaleFunctionY(y) - viewModel.labelMargin),
                                    anchor: .bottomTrailing
                                )
                            } else {
                                ctx.draw(
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
                                ctx.stroke(path, with: .color(.primary), lineWidth: viewModel.axisLineWidth)
                            }
                        }
                    }

                    // xAxis Label(Original Number)
                    Canvas { ctx, _ in
                        let tick = viewModel.xAxis.tick
                        let scaleFunctionX = viewModel.xAxis.scaleFunction
                        let scaleFunctionY = viewModel.yAxis.scaleFunction
                        for i in 0 ... viewModel.xAxis.tickCount {
                            let x = tick.start + CGFloat(i) * tick.step
                            if x == 0.0, viewModel.extentX.min < 0 {
                                ctx.draw(
                                    Text(String(format: "%.2f", x))
                                        .font(viewModel.axisLabelFont),
                                    at: .init(x: scaleFunctionX(x) + viewModel.labelMargin, y: scaleFunctionY(viewModel.yAxis.scale.domainExtent.min) + viewModel.labelMargin),
                                    anchor: .topLeading
                                )
                            } else {
                                ctx.draw(
                                    Text(String(format: "%.2f", x))
                                        .font(viewModel.axisLabelFont),
                                    at: .init(x: scaleFunctionX(x), y: scaleFunctionY(viewModel.yAxis.scale.domainExtent.min) + viewModel.labelMargin),
                                    anchor: .top
                                )

                                // Tick Mark
                                let path = Path {
                                    $0.move(to: .init(x: scaleFunctionX(x), y: scaleFunctionY(viewModel.yAxis.scale.domainExtent.min)))
                                    $0.addLine(to: .init(x: scaleFunctionX(x), y: scaleFunctionY(viewModel.yAxis.scale.domainExtent.min) + viewModel.tickMarkHeight))
                                }
                                ctx.stroke(path, with: .color(Color(Asset.dynamicBlack.color)), lineWidth: viewModel.axisLineWidth)
                            }
                        }
                    }
                    .opacity(0)

                    // xAxis Label
                    Canvas { ctx, _ in
                        for label in viewModel.xLabels {
                            let scaleFunctionX = viewModel.xAxis.scaleFunction
                            let scaleFunctionY = viewModel.yAxis.scaleFunction
                            let dataPointScale = viewModel.dataScaleX.scale()
                            if let _x = dataPointScale(label) {
                                let x = scaleFunctionX(_x)
                                let str = "\(label)"
                                ctx.draw(
                                    Text(str)
                                        .font(viewModel.axisLabelFont),
                                    at: .init(x: x, y: scaleFunctionY(viewModel.yAxis.scale.domainExtent.min) + viewModel.labelMargin),
                                    anchor: .top
                                )

                                // Tick Mark
                                let path = Path {
                                    $0.move(to: .init(x: x, y: scaleFunctionY(viewModel.yAxis.scale.domainExtent.min)))
                                    $0.addLine(to: .init(x: x, y: scaleFunctionY(viewModel.yAxis.scale.domainExtent.min) - viewModel.tickMarkHeight))
                                }
                                ctx.stroke(path, with: .color(Color(Asset.dynamicBlack.color)), lineWidth: viewModel.axisLineWidth)
                            }
                        }
                    }

                    // yAxis
                    Canvas { ctx, _ in
                        let path = Path {
                            let scaleFunctionX = viewModel.xAxis.scaleFunction
                            let scaleFunctionY = viewModel.yAxis.scaleFunction

                            $0.move(to: .init(x: scaleFunctionX(0), y: scaleFunctionY(viewModel.yAxis.scale.domainExtent.min)))
                            $0.addLine(to: .init(x: scaleFunctionX(0), y: scaleFunctionY(viewModel.yAxis.scale.domainExtent.max)))
                        }
                        ctx.stroke(path, with: .color(Color(Asset.dynamicBlack.color)), lineWidth: viewModel.axisLineWidth)
                    }

                    // xAxis
                    Canvas { ctx, _ in
                        let path = Path {
                            let scaleFunctionY = viewModel.yAxis.scaleFunction
                            let scaleFunctionX = viewModel.xAxis.scaleFunction

                            $0.move(to: .init(x: scaleFunctionX(viewModel.xAxis.scale.domainExtent.min), y: scaleFunctionY(viewModel.yAxis.scale.domainExtent.min)))
                            $0.addLine(to: .init(x: scaleFunctionX(viewModel.xAxis.scale.domainExtent.max), y: scaleFunctionY(viewModel.yAxis.scale.domainExtent.min)))
                        }
                        ctx.stroke(path, with: .color(Color(Asset.dynamicBlack.color)), lineWidth: viewModel.axisLineWidth)
                    }
                    #endif

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
                            path.move(to: .init(x: xStart, y: viewModel.yAxis.scale.scale()(viewModel.yAxis.scale.domainExtent.min)))

                            for key in dataSource.keys {
                                let (x, y) = calXY(key)
                                path.addLine(to: .init(x: x, y: y))
                            }

                            let (xEnd, _) = calXY(dataSource.keys.last!)
                            path.addLine(to: .init(x: xEnd, y: viewModel.yAxis.scale.scale()(viewModel.yAxis.scale.domainExtent.min)))
                            path.addLine(to: .init(x: xStart, y: viewModel.yAxis.scale.scale()(viewModel.yAxis.scale.domainExtent.min)))
                        }
                        .fill(viewModel.lineColor(dataSource: dataSource).opacity(0.2))
                        .onTapGesture {
                            print(viewModel.lineColor(dataSource: dataSource))
                        }
                    }

                    #if os(macOS)
                    // Original Point
                    Canvas { ctx, _ in
                        let scaleFunctionY = viewModel.yAxis.scaleFunction
                        let scaleFunctionX = viewModel.xAxis.scaleFunction
                        let r = viewModel.originalPointRidius
                        let point = Path(ellipseIn: .init(x: scaleFunctionX(0) - r, y: scaleFunctionY(viewModel.yAxis.scale.domainExtent.min) - r, width: 2 * r, height: 2 * r))
                        ctx.fill(point, with: .color(Color(Asset.dynamicBlack.color)))
                    }
                    .allowsHitTesting(false)
                    #endif

                    // Pointer
                    Group {
                        Canvas { ctx, _ in
                            if let pointerPosition = pointerPosition {
                                let x = pointerPosition.x
                                let y = pointerPosition.y

                                let transfromedDataY = viewModel.yAxis.scale.invert()(y)
                                let transfromedDataX = viewModel.dataScaleX.invert()(viewModel.xAxis.scale.invert()(x))
                                let roundedX = viewModel.xAxis.scale.scale()(viewModel.dataScaleX.scale()(transfromedDataX)!)

                                let xLinePath = Path {
                                    $0.move(to: .init(x: viewModel.xAxis.scaleFunction(0), y: y))
                                    $0.addLine(to: .init(x: roundedX, y: y))
                                }

                                let shading = GraphicsContext.Shading.color(Color(Asset.dynamicBlack.color).opacity(0.8))
                                let style = StrokeStyle(lineWidth: viewModel.axisLineWidth / 1.5, dash: [6, 3])
                                ctx.stroke(xLinePath, with: shading, style: style)

                                let yLinepath = Path {
                                    $0.move(to: .init(x: roundedX, y: viewModel.yAxis.scaleFunction(viewModel.yAxis.scale.domainExtent.min)))
                                    $0.addLine(to: .init(x: roundedX, y: y))
                                }
                                ctx.stroke(yLinepath, with: .color(Color(Asset.dynamicBlack.color).opacity(0.8)), style: .init(lineWidth: viewModel.axisLineWidth / 1.5, dash: [6, 3]))

                                let r = viewModel.originalPointRidius
                                let point = Path(ellipseIn: .init(x: roundedX - r, y: y - r, width: 2 * r, height: 2 * r))
                                ctx.fill(point, with: .color(Color(Asset.dynamicBlack.color)))

                                let str = "\(transfromedDataX), \(transfromedDataY)"
                                let strWidth = str.widthOfString(usingFont: viewModel.axisLabelTraditionalFont)
                                if roundedX + viewModel.labelMargin + strWidth > viewModel.size.width {
                                    ctx.draw(
                                        Text(str)
                                            .font(viewModel.axisLabelFont),
                                        at: .init(x: roundedX - viewModel.labelMargin, y: y - viewModel.labelMargin),
                                        anchor: .bottomTrailing
                                    )
                                } else {
                                    ctx.draw(
                                        Text(str)
                                            .font(viewModel.axisLabelFont),
                                        at: .init(x: roundedX + viewModel.labelMargin, y: y - viewModel.labelMargin),
                                        anchor: .bottomLeading
                                    )
                                }

                                for dataSource in viewModel.dataSources {
                                    if let identicalElement = dataSource.keys.first(where: { $0 == transfromedDataX }) {
                                        let data = dataSource.data[identicalElement]!

                                    }
                                }
                            }
                        }
                        .allowsHitTesting(false)
                    }
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: .zero)
                        .onChanged { value in
                            pointerPosition = value.location
                        }
                )
            }
            .if(animationDisabled) { view in
                view.animation(nil)
            }
        }
    }
}
