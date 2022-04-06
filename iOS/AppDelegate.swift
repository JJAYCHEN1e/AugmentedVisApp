//
//  AppDelegate.swift
//  AugmentedVisApp
//
//  Created by jjaychen on 2021/10/13.
//

import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)

        let rootVC = StoryboardScene.ARVisViewController.arVisViewController.instantiate()
//        let rootVC = UIHostingController(rootView: PieChart_Previews.previews)
        window.rootViewController = rootVC
        window.makeKeyAndVisible()

        self.window = window
        return true
    }
}
