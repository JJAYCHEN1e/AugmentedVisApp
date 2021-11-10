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
            .hStack(elements: [
                .vStack(
                    elements: [
                        .text(content: "Source Code Walkthrough of Telegram-iOS: Part 1",
                              multilineTextAlignment: .leading,
                              fontStyle: .init(size: 21, weight: .bold)),
                        .text(content: "Overview of the Code", fontStyle: .init(size: 17, weight: .bold)),
                        .text(content: "Telegram-iOS organizes the source code by over 200 [submodules](https://github.com/TelegramMessenger/Telegram-iOS/tree/master/submodules) with more than two million lines of code. I roughly put these modules into five categories:",
                              fontStyle: .init(size: 15)),
                        .text(content: "- **App**, modules that support the main app features, like foundation utils, UI, network, etc.", fontStyle: .init(size: 15)),
                        .text(content: "- **VoIP**, the feature of voice calls which was released at the end of March 2017.", fontStyle: .init(size: 15)),
                        .text(content: "- **Watch**, the Watch app.", fontStyle: .init(size: 15)),
                        .text(content: "- **TON**, the experimental integration with the new blockchain platform.", fontStyle: .init(size: 15)),
                        .text(content: "- **3rd-party**, the other open-source projects it depends on.", fontStyle: .init(size: 15)),
                        .text(content: "Here is the **LOC/File Count/Submodules statistic** of each category.", fontStyle: .init(size: 15)),
                        .text(content: "Telegram-iOS is a mixed language project. By looking into the **App** category, there are nearly **70%** code in **Swift** and **24%** in **Objective-C/C++**.", fontStyle: .init(size: 15)),
                        .text(content: "Below is the testing part of view info component.", fontStyle: .init(size: 15)),
                        .text(content: "**图片**:", fontStyle: .init(size: 17)),
                        .image(url: "https://docs-assets.developer.apple.com/published/40830bd30299f78853b33000a97b45c0/11800/06030H~dark@2x.png", contentMode: .fit),
                        .text(content: "**视频**:", fontStyle: .init(size: 17)),
                        .video(url: "https://www.ecnu.edu.cn/video/bannershipindiyiqi_05.mp4")
                    ],
                    alignment: .center,
                    spacing: 10
                ),
                .spacer()
            ])
    }

    static var sampleViewInfoComponent_InvalidHexString: ViewInfoComponent {
        return .text(content: "123", fontStyle: .init(size: 17, color: .rgbaHex(string: "FFF")))
    }
}
