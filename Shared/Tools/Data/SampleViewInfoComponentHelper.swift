//
//  SampleViewInfoComponentHelper.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/10/29.
//

import Foundation

class SampleViewInfoComponentHelper {
    static var sampleViewInfoComponent: ViewInfoComponent {
        return
            .vStack(
                elements: [
                    .text(content: "2021 年第三季度报表",
                          multilineTextAlignment: .leading,
                          fontStyle: .init(size: 24, weight: .bold,color: .white)),
                    .hStack(elements: [
                        .spacer(),
                        .text(content: "**统计日期**: 2021-11-01", fontStyle: .init(size: 17, color: .white)),
                    ]),
                    .text(content: "支持自定义文字颜色、大小、位置及对齐方式。Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut ac eros nisi. Lorem ipsum dolor sit amet.",
                          fontStyle: .init(size: 30, weight: .bold, design: .default, color: .blue)),
                    .hStack(elements: [
                        .text(content: "**图片**:", fontStyle: .init(size: 17, color: .white)),
                        .spacer(),
                    ]),
                    .image(url: "https://docs-assets.developer.apple.com/published/40830bd30299f78853b33000a97b45c0/11800/06030H~dark@2x.png", contentMode: .fit),
                    .hStack(elements: [
                        .text(content: "**分析视频**:", fontStyle: .init(size: 17, color: .white)),
                            .spacer(),
                    ]),
                    .video(url: "https://bit.ly/swswift"),
                    .spacer()
                ],
                alignment: .center,
                spacing: 10
            )
    }

    static var sampleViewInfoComponent_InvalidHexString: ViewInfoComponent {
        return .text(content: "123", fontStyle: .init(size: 17, color: .rgbaHex(string: "FFF")))
    }
}
