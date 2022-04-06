//
//  Enums.swift
//  AugmentedVisApp
//
//  Created by 陈俊杰 on 2021/10/28.
//

import Foundation
import SwiftUI
import UIColorHexSwift

// MARK: - ContentMode
enum ContentMode: String, Codable {
    case fit
    case fill

    fileprivate func toSwiftUIContentMode() -> SwiftUI.ContentMode {
        switch self {
        case .fit:
            return .fit
        case .fill:
            return .fill
        }
    }
}

extension SwiftUI.ContentMode {
    init(_ contentMode: ContentMode) {
        self = contentMode.toSwiftUIContentMode()
    }
}

extension View {
    func aspectRatio(_ aspectRatio: CGFloat? = nil, contentMode: ContentMode) -> some View {
        self.aspectRatio(aspectRatio, contentMode: .init(contentMode))
    }
}

// MARK: - TextAlignment
enum AVTextAlignment: String, Codable {
    case center
    case leading
    case trailing

    fileprivate func toSwiftUITextAlignment() -> SwiftUI.TextAlignment {
        switch self {
        case .center:
            return .center
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }
}

extension SwiftUI.TextAlignment {
    init(_ textAlignment: AVTextAlignment) {
        self = textAlignment.toSwiftUITextAlignment()
    }
}

extension View {
    func multilineTextAlignment(_ alignment: AVTextAlignment) -> some View {
        self.multilineTextAlignment(.init(alignment))
    }
}

// MARK: - HorizontalAlignment
enum HorizontalAlignment: String, Codable {
    case center
    case leading
    case trailing

    fileprivate func toSwiftUIHorizontalAlignment() -> SwiftUI.HorizontalAlignment {
        switch self {
        case .center:
            return .center
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }
}

extension SwiftUI.HorizontalAlignment {
    init(_ horizontalAlignment: HorizontalAlignment) {
        self = horizontalAlignment.toSwiftUIHorizontalAlignment()
    }
}

// MARK: - HorizontalAlignment
enum VerticalAlignment: String, Codable {
    case center
    case top
    case bottom

    fileprivate func toSwiftUIVerticalAlignment() -> SwiftUI.VerticalAlignment {
        switch self {
        case .center:
            return .center
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }
}

extension SwiftUI.VerticalAlignment {
    init(_ verticalAlignment: VerticalAlignment) {
        self = verticalAlignment.toSwiftUIVerticalAlignment()
    }
}

// MARK: - FontStyle
struct FontStyle: Codable, Equatable {
    let size: CGFloat
    let weight: Weight?
    let design: Design?
    let color: AVColor?

    init(size: CGFloat, weight: FontStyle.Weight? = nil, design: FontStyle.Design? = nil, color: AVColor? = nil) {
        self.size = size
        self.weight = weight
        self.design = design
        self.color = color
    }

}

extension SwiftUI.Font {
    init?(_ fontStyle: FontStyle?) {
        if let fontStyle = fontStyle {
            self = .system(size: fontStyle.size,
                           weight: fontStyle.weight != nil ? .init(fontStyle.weight!) : .regular,
                           design: fontStyle.design != nil ? .init(fontStyle.design!) : .default)
        } else {
            return nil
        }
    }
}

extension FontStyle {
    enum Weight: String, Codable, Equatable {
        case black
        case bold
        case heavy
        case light
        case medium
        case regular
        case semibold
        case thin
        case ultraLight

        fileprivate func toSwiftUIFontWeight() -> SwiftUI.Font.Weight {
            switch self {
            case .black:
                return .black
            case .bold:
                return .bold
            case .heavy:
                return .heavy
            case .light:
                return .light
            case .medium:
                return .medium
            case .regular:
                return .regular
            case .semibold:
                return .semibold
            case .thin:
                return .thin
            case .ultraLight:
                return .ultraLight
            }
        }
    }
}

extension SwiftUI.Font.Weight {
    init(_ weight: FontStyle.Weight) {
        self = weight.toSwiftUIFontWeight()
    }
}

extension FontStyle {
    enum Design: String, Codable, Equatable {
        case `default`
        case monospaced
        case rounded
        case serif

        fileprivate func toSwiftUIFontDesign() -> SwiftUI.Font.Design {
            switch self {
            case .default:
                return .default
            case .monospaced:
                return .monospaced
            case .rounded:
                return .rounded
            case .serif:
                return .serif
            }
        }
    }
}

extension SwiftUI.Font.Design {
    init(_ design: FontStyle.Design) {
        self = design.toSwiftUIFontDesign()
    }
}

// MARK: - AVColor
enum AVColor: Equatable {
    case black
    case blue
    case brown
    case clear
    case cyan
    case gray
    case green
    case indigo
    case mint
    case orange
    case pink
    case purple
    case red
    case teal
    case white
    case yellow
    case rgba(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0)
    case rgba256(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 255.0)
    case rgbaHex(string: String)

    fileprivate func toSwiftUIColor() -> SwiftUI.Color {
        switch self {
        case .black:
            return .black
        case .blue:
            return .blue
        case .brown:
            return .brown
        case .clear:
            return .clear
        case .cyan:
            return .cyan
        case .gray:
            return .gray
        case .green:
            return .green
        case .indigo:
            return .indigo
        case .mint:
            return .mint
        case .orange:
            return .orange
        case .pink:
            return .pink
        case .purple:
            return .purple
        case .red:
            return .red
        case .teal:
            return .teal
        case .white:
            return .white
        case .yellow:
            return .yellow
        case .rgba(let r, let g, let b, let a):
            return .init(.sRGB, red: min(1, r), green: min(1, g), blue: min(1, b), opacity: min(1, a))
        case .rgba256(let r, let g, let b, let a):
            return .init(.sRGB, red: min(1, r / 255), green: min(1, g / 255), blue: min(1, b / 255), opacity: min(1, a / 255))
        case .rgbaHex(let string):
            return Color(hex: string)
        }
    }

    init(_ color: Color) {
        let components = color.components
        self = .rgba(r: components.red, g: components.green, b: components.blue, a: components.opacity)
    }
}

extension AVColor: RawRepresentable {
    typealias RawValue = String

    var rawValue: String {
        switch self {
        case .black, .blue, .brown, .clear, .cyan, .gray, .green, .indigo, .mint, .orange, .pink, .purple, .red, .teal, .white, .yellow:
            return "\(self)"
        default:
            return ""
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case "black":
            self = .black
        case "blue":
            self = .blue
        case "brown":
            self = .brown
        case "clear":
            self = .clear
        case "cyan":
            self = .cyan
        case "gray":
            self = .gray
        case "green":
            self = .green
        case "indigo":
            self = .indigo
        case "mint":
            self = .mint
        case "orange":
            self = .orange
        case "pink":
            self = .pink
        case "purple":
            self = .purple
        case "red":
            self = .red
        case "teal":
            self = .teal
        case "white":
            self = .white
        case "yellow":
            self = .yellow
        default:
            return nil
        }
    }

}

extension AVColor: Codable {
    enum CodingKeys: String, CodingKey {
        case rgba
        case rgba256
        case rgbaString
    }

    fileprivate enum DumbAVColor: Codable {
        case rgba(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
        case rgba256(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)

        init?(_ avColor: AVColor) {
            switch avColor {
            case .rgba(let r, let g, let b, let a):
                self = .rgba(r: r, g: g, b: b, a: a)
            case .rgba256(let r, let g, let b, let a):
                self = .rgba256(r: r, g: g, b: b, a: a)
            default:
                return nil
            }
        }
    }

    fileprivate init?(_ dumbAVColor: DumbAVColor) {
        switch dumbAVColor {
        case .rgba(let r, let g, let b, let a):
            self = .rgba(r: r, g: g, b: b, a: a)
        case .rgba256(let r, let g, let b, let a):
            self = .rgba256(r: r, g: g, b: b, a: a)
        }
    }

    static private func checkHexStringValidity(string hexString: String) throws -> Bool {
        guard hexString.hasPrefix("#") else {
            let error = PlatformColorInputError.missingHashMarkAsPrefix(hexString)
            throw error
        }

        switch hexString.dropFirst().count {
        case 3:
            return true
        case 4:
            return true
        case 6:
            return true
        case 8:
            return true
        default:
            let error = PlatformColorInputError.mismatchedHexStringLength(hexString)
            throw error
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .black, .blue, .brown, .clear, .cyan, .gray, .green, .indigo, .mint, .orange, .pink, .purple, .red, .teal, .white, .yellow:
            try container.encode("\(self)")
        case .rgba, .rgba256:
            try container.encode(DumbAVColor(self))
        case .rgbaHex(let string):
            try container.encode(string)
        }
    }

    init(from decoder: Decoder) throws {
        let context = DecodingError.Context(
            codingPath: [],
            debugDescription: "Data corrupted.")

        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            // rgb, rgba
            if container.allKeys.count != 1 {
                let context = DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid number of keys found, expected one.")
                throw DecodingError.typeMismatch(AVColor.self, context)
            }

            let container = try decoder.singleValueContainer()
            let dumbAVColor = try container.decode(DumbAVColor.self)
            if let avColor = AVColor(dumbAVColor) {
                self = avColor
            } else {
                throw DecodingError.dataCorrupted(context)
            }
        } else if let container = try? decoder.singleValueContainer() {
            // single value
            let decodeResultString = try container.decode(String.self)
            if let decodeResult = AVColor(rawValue: decodeResultString) {
                // blue, white, gray...
                self = decodeResult
            } else if try AVColor.checkHexStringValidity(string: decodeResultString) {
                self = .rgbaHex(string: decodeResultString)
            } else {
                let context = DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid string found: \(decodeResultString).")
                throw DecodingError.dataCorrupted(context)
            }
        } else {
            // Never Enter Here
            throw DecodingError.dataCorrupted(context)
        }
    }

}

extension SwiftUI.Color {
    init?(_ color: AVColor?) {
        if let color = color {
            self = color.toSwiftUIColor()
        } else {
            return nil
        }
    }

    init(_ color: AVColor) {
        self = color.toSwiftUIColor()
    }
}
