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
                    .text(content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut ac eros nisi. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut vitae massa aliquam, vulputate elit in, aliquet tellus. Donec volutpat, nisi lobortis aliquam vehicula, mauris turpis imperdiet velit, egestas posuere nisl arcu quis magna. Maecenas at ex vehicula, euismod odio vel, gravida arcu. Integer vestibulum posuere tempus. Nunc euismod nibh at neque efficitur, quis cursus dolor volutpat. Duis finibus fringilla justo, nec vestibulum lorem faucibus ut. Mauris ut augue in arcu lacinia convallis.",
                          multilineTextAlignment: .leading,
                          fontStyle: .init(size: 17, color: .rgba(r: 0.5, g: 0.5, b: 0.5, a: 0.5))),
                    .hStack(elements: [
                        .text(content: "2行左", fontStyle: .init(size: 17, color: .rgba256(r: 255, g: 0, b: 0))),
                        .spacer(),
                        .text(content: "2行右", fontStyle: .init(size: 17, color: .rgbaString(string: "#FFF")))
                    ]),
                    .text(content: "第三行",
                          fontStyle: .init(size: 20, weight: .bold, design: .default, color: .blue)),
                    .image(url: "https://docs-assets.developer.apple.com/published/40830bd30299f78853b33000a97b45c0/11800/06030H~dark@2x.png", contentMode: .fit),
                    .video(url: "https://bit.ly/swswift"),
                    .spacer()
                ],
                alignment: .center,
                spacing: 10
            )
    }

    static var sampleViewInfoComponent_InvalidHexString: ViewInfoComponent {
        return
            .vStack(
                elements: [
                    .text(content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut ac eros nisi. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut vitae massa aliquam, vulputate elit in, aliquet tellus. Donec volutpat, nisi lobortis aliquam vehicula, mauris turpis imperdiet velit, egestas posuere nisl arcu quis magna. Maecenas at ex vehicula, euismod odio vel, gravida arcu. Integer vestibulum posuere tempus. Nunc euismod nibh at neque efficitur, quis cursus dolor volutpat. Duis finibus fringilla justo, nec vestibulum lorem faucibus ut. Mauris ut augue in arcu lacinia convallis.",
                          multilineTextAlignment: .leading,
                          fontStyle: .init(size: 17, color: .rgba(r: 0.5, g: 0.5, b: 0.5, a: 0.5))),
                    .hStack(elements: [
                        .text(content: "2行左", fontStyle: .init(size: 17, color: .rgba256(r: 255, g: 0, b: 0))),
                        .spacer(),
                        .text(content: "2行右", fontStyle: .init(size: 17, color: .rgbaString(string: "FFF")))
                    ]),
                    .text(content: "第三行",
                          fontStyle: .init(size: 20, weight: .bold, design: .default, color: .blue)),
                    .image(url: "https://docs-assets.developer.apple.com/published/40830bd30299f78853b33000a97b45c0/11800/06030H~dark@2x.png", contentMode: .fit),
                    .video(url: "https://bit.ly/swswift"),
                    .spacer()
                ],
                alignment: .center,
                spacing: 10
            )
    }
}
