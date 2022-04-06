//
//  PreviewContainerViewController.swift
//  AugmentedVisApp (macOS)
//
//  Created by 陈俊杰 on 2021/11/8.
//

import AppKit
import SwiftUI
// swiftlint:disable type_name
struct PreviewContainerViewControllerRepresentable<V: View>: NSViewControllerRepresentable {

    let chartView: V

    func makeNSViewController(context: Context) -> PreviewContainerViewController<V> {
        PreviewContainerViewController(chartView: chartView)
    }

    func updateNSViewController(_ nsViewController: PreviewContainerViewController<V>, context: Context) {

    }

    typealias NSViewControllerType = PreviewContainerViewController<V>

}

class PreviewContainerViewController<V: View>: NSViewController {

    let chartView: V

    init(chartView: V) {
        self.chartView = chartView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        let qrCodeSize = ImageGenerateHelper.qrCodeSize
        let graphWidth = ImageGenerateHelper.graphWidth
        let graphHeight = ImageGenerateHelper.graphHeight
        let padding = ImageGenerateHelper.padding

        view.frame = .init(x: 0, y: 0, width: graphWidth + padding + qrCodeSize, height: graphHeight)

        let containerView = NSView()
        containerView.frame = view.frame

        let vc = NSHostingController(rootView: chartView)
        vc.view.frame = .init(x: 0, y: 0, width: graphWidth, height: graphHeight)
        containerView.addSubview(vc.view)

        let qrCodeView = NSImageView(image: NSImage(named: "flower2")!)
        containerView.addSubview(qrCodeView)
        qrCodeView.frame = .init(x: graphWidth + padding, y: 0, width: qrCodeSize, height: qrCodeSize)

        view.addSubview(containerView)

        let button = Button {
            containerView.makePNGFromView()
        } label: {
            Text("Save")
        }
        .padding(.bottom)
        let buttonView = NSHostingView(rootView: button)
        view.addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
