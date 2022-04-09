//
//  EditorPanel.swift
//  AugmentedVisApp (macOS)
//
//  Created by 陈俊杰 on 2022/3/12.
//

import SwiftUI
import WebKit

struct Margin: Decodable {
    var top: Double
    var right: Double
    var bottom: Double
    var left: Double
}

struct VisInfo: Decodable {
    var width: Double
    var height: Double
    var margin: Margin
    var outerRootSVG: String
    var innerRootGroup: String
    var xAxisGroup: String?
    var yAxisGroup: String?
    var dataComponents: [String]
}

class EditorPanelViewController: PlatformViewController, WKNavigationDelegate, WKScriptMessageHandler {
    private var wkWebView: WKWebView!

    override func loadView() {
        let wkWebView = WKWebView()
        view = wkWebView
        self.wkWebView = wkWebView
    }

    override func viewDidLoad() {
        wkWebView.navigationDelegate = self

        // Add message handler for `logging`
        wkWebView.configuration.userContentController.add(self, name: "logging")

        // Load EditorPanel's html file
        wkWebView.loadFileURL(Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "EditorPanel")!, allowingReadAccessTo: Bundle.main.resourceURL!)
    }

    // MARK: WKNavigateDelegate

    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        // Set EditorPanel's magnification
        wkWebView.pageZoom = 1.25
    }

    // MARK: WKScriptMessageHandler

    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        if let bodyStr = message.body as? String,
           let data = bodyStr.data(using: .utf8) {
            if let visInfo = try? JSONDecoder().decode(VisInfo.self, from: data) {
                SVGContent.shared.visInfo = visInfo
            }
        }
        print("WKWebView Message: \(message.body)")
    }
}

struct EditorPanelViewControllerRepresentable: PlatformViewControllerRepresentable {
    typealias NSViewControllerType = EditorPanelViewController

    func makeNSViewController(context _: Context) -> EditorPanelViewController {
        EditorPanelViewController()
    }

    func updateNSViewController(_: EditorPanelViewController, context _: Context) {}
}
