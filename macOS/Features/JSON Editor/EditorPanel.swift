//
//  EditorPanel.swift
//  AugmentedVisApp (macOS)
//
//  Created by 陈俊杰 on 2022/3/12.
//

import SwiftUI
import WebKit

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
//        let body = message.body
//        if let jsonData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted),
//           let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) {
//            print(jsonObject)
//            print(String(data: jsonData, encoding: .utf8)!)
//        }
//        if let dic = body as? [String: Any] {
//            print("dic")
//        }
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
