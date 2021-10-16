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
            print("NIL")
            return
        }
        rep.size = self.bounds.size
        self.cacheDisplay(in: self.bounds, to: rep)
        if let data = rep.representation(using: .png, properties: [:]) {
            do {
                let path = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].appendingPathComponent("\(Date().timeIntervalSince1970).png")
                try data.write(to: path, options: .atomic)
            } catch {
                print(error)
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
            let padding: CGFloat = 16.0
            let qrCodeSize: CGFloat = 240.0
            let graphWidth: CGFloat = 1920.0
            let graphHeight: CGFloat = 1080.0

            let rootVC = NSViewController()
            rootVC.view = NSView()
            rootVC.view.frame = .init(x: 0, y: 0, width: (graphWidth + padding + qrCodeSize) / 2, height: graphHeight / 2)

            let vc = NSHostingController(rootView: self)
            vc.view.frame = .init(x: 0, y: 0, width: graphWidth / 2, height: graphHeight / 2)
            rootVC.view.addSubview(vc.view)

            let qrCodeView = NSImageView(image: NSImage(named: "flower2")!)
            rootVC.view.addSubview(qrCodeView)
            qrCodeView.frame = .init(x: (graphWidth + padding) / 2, y: 0, width: qrCodeSize / 2, height: qrCodeSize / 2)

            rootVC.view.makePNGFromView()
        }
    }
}
