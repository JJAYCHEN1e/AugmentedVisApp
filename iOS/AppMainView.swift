//
//  AppMainView.swift
//  AppMainView
//
//  Created by jjaychen on 2021/10/13.
//

import SwiftUI
import UIKit

struct ARVisViewControllerRepresentable: UIViewControllerRepresentable {
	typealias UIViewControllerType = ARVisViewController
	
	func makeUIViewController(context: Context) -> ARVisViewController {
		return StoryboardScene.ARVisViewController.arVisViewController.instantiate()
	}
	
	func updateUIViewController(_ uiViewController: ARVisViewController, context: Context) {
		return
	}
	
}

struct AppMainView: View {
    var body: some View {
		ARVisViewControllerRepresentable()
//			.edgesIgnoringSafeArea(.all)
    }
}
