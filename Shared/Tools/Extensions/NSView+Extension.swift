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
