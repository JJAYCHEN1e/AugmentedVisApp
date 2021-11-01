//
//  UIViewController+Extension.swift
//  UIViewController+Extension
//
//  Created by jjaychen on 2021/10/15.
//

import AppKit
import SwiftUI
import Foundation

extension NSView {
    func makePNGFromView() {
        guard let rep = self.bitmapImageRepForCachingDisplay(in: self.bounds) else {
            fatalError("Save failed")
        }
        rep.size = self.bounds.size
        self.cacheDisplay(in: self.bounds, to: rep)
        if let data = rep.representation(using: .png, properties: [:]) {
            do {
                let path = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].appendingPathComponent("\(Date().timeIntervalSince1970).png")
                try data.write(to: path, options: .atomic)
            } catch {
                print(error)
                fatalError(error.localizedDescription)
            }
        }
    }
}

extension View {
    func snapshot() {
        DispatchQueue.main.async {
            let vc = NSHostingController(rootView: self)
            vc.view.frame = .init(x: 0, y: 0, width: 1920 / 2, height: 1080 / 2)
            vc.view.makePNGFromView()
        }
    }

    func snapshotMock() {
        DispatchQueue.main.async {
            let qrCodeSize = ImageGenerateHelper.qrCodeSize
            let graphWidth = ImageGenerateHelper.graphWidth
            let graphHeight = ImageGenerateHelper.graphHeight
            let padding = ImageGenerateHelper.padding

            let rootVC = NSViewController()
            rootVC.view = NSView()
            rootVC.view.frame = .init(x: 0, y: 0, width: graphWidth + padding + qrCodeSize, height: graphHeight)

            let vc = NSHostingController(rootView: self)
            vc.view.frame = .init(x: 0, y: 0, width: graphWidth, height: graphHeight)
            rootVC.view.addSubview(vc.view)

            let qrCodeView = NSImageView(image: NSImage(named: "flower2")!)
            rootVC.view.addSubview(qrCodeView)
            qrCodeView.frame = .init(x: graphWidth + padding, y: 0, width: qrCodeSize, height: qrCodeSize)

            rootVC.view.makePNGFromView()
        }
    }
}
