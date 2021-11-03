//
//  ViewInfoComponent.swift
//  ViewInfoComponent
//
//  Created by jjaychen on 2021/10/23.
//

import Foundation
import SwiftUI
import AVKit

struct ViewInfoComponent: Equatable, Codable {
    internal let viewInfo: ViewInfo

    fileprivate init(_ viewInfo: ViewInfo) {
        self.viewInfo = viewInfo
    }
    
    var view: some View {
        viewInfo.view()
    }

    static func text(content: String, multilineTextAlignment: AVTextAlignment = .center, fontStyle: FontStyle? = nil) -> ViewInfoComponent {
        ViewInfoComponent(.text(content: content, multilineTextAlignment: multilineTextAlignment, fontStyle: fontStyle))
    }
    
    static func image(url: String, contentMode: ContentMode = .fit) -> ViewInfoComponent {
        ViewInfoComponent(.image(url: url, contentMode: contentMode))
    }
    
    static func video(url: String) -> ViewInfoComponent {
        ViewInfoComponent(.video(url: url))
    }

    static func hStack(elements: [ViewInfoComponent], alignment: VerticalAlignment = .center, spacing: CGFloat? = nil) -> ViewInfoComponent {
        ViewInfoComponent(.hStack(elements: elements.map { $0.viewInfo }, alignment: alignment, spacing: spacing))
    }
    
    static func vStack(elements: [ViewInfoComponent], alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil) -> ViewInfoComponent {
        ViewInfoComponent(.vStack(elements: elements.map { $0.viewInfo }, alignment: alignment, spacing: spacing))
    }
    
    static func spacer() -> ViewInfoComponent {
        ViewInfoComponent(.spacer)
    }
    
}

fileprivate struct IdentifiableViewInfo: Identifiable {
    var id = UUID()
    let viewInfo: ViewInfo
    
    fileprivate init(_ viewInfo: ViewInfo) {
        self.viewInfo = viewInfo
    }
    
    var view: some View {
        viewInfo.view()
    }
}

internal enum ViewInfo: Codable, Equatable {
    // font
    case text(content: String, multilineTextAlignment: AVTextAlignment = .center, fontStyle: FontStyle? = nil)
    case image(url: String, contentMode: ContentMode = .fit)
    case video(url: String)
    case link(url: String) // how to integrate into text?
    //    case superLink(link: AnyView)
    case hStack(elements: [ViewInfo], alignment: VerticalAlignment = .center, spacing: CGFloat? = nil)
    case vStack(elements: [ViewInfo], alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil)
    case spacer
}

extension ViewInfo {
    @ViewBuilder
    fileprivate func view() -> some View {
        switch self {
        case .text(let content, let multilineTextAlignment, let fontStyle):
            Text(LocalizedStringKey(content), tableName: nil)
                .font(.init(fontStyle))
                .foregroundColor(.init(fontStyle?.color))
                .multilineTextAlignment(multilineTextAlignment)
        case .image(let url, let contentMode):
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .init(contentMode))
            } placeholder: {
                ProgressView()
            }
        case .video(let url):
            VideoPlayer(player: URL(string: url) != nil ? AVPlayer(url: URL(string: url)!) : nil)
                .frame(minHeight: 200, maxHeight: 900)
//                .frame(width: 100.0, height: 100.0)
        case .hStack(let elements, let alignment, let spacing):
            HStack(alignment: .init(alignment), spacing: spacing) {
                ForEach(elements.map { $0.wrappedInContainer() }) { element in
                    AnyView(element.view)
                }
            }
        case .vStack(let elements, let alignment, let spacing):
            VStack(alignment: .init(alignment), spacing: spacing) {
                ForEach(elements.map { $0.wrappedInContainer() }) { element in
                    AnyView(element.view)
                }
            }
        case .spacer:
            Spacer()
        default:
            Text("Default")
        }
    }
    
    fileprivate func wrappedInContainer() -> IdentifiableViewInfo {
        IdentifiableViewInfo(self)
    }
}

