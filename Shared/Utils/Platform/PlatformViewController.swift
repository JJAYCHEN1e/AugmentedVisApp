//
//  PlatformViewController.swift
//  AugmentedVisApp (macOS)
//
//  Created by 陈俊杰 on 2022/3/12.
//

import SwiftUI

#if os(iOS)
import UIKit
typealias PlatformViewController = UIViewController
typealias PlatformViewControllerRepresentable = UIViewControllerRepresentable
typealias PlatformViewRepresentable = UIViewRepresentable
#elseif os(macOS)
import Cocoa
import SafariServices
typealias PlatformViewController = NSViewController
typealias PlatformViewControllerRepresentable = NSViewControllerRepresentable
typealias PlatformViewRepresentable = NSViewRepresentable
#endif
