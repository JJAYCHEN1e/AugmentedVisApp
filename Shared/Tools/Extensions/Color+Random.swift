//
//  Color+Random.swift
//  AugmentedVisApp (iOS)
//
//  Created by 陈俊杰 on 2021/11/10.
//

import SwiftUI

// Random Colors
extension Color {
    static public var originalPresetColors: [Color] = [
        Color(hex: "#4e79a7"),
        Color(hex: "#f28e2c"),
        Color(hex: "#e15759"),
        Color(hex: "#76b7b2"),
        Color(hex: "#59a14f"),
        Color(hex: "#edc949"),
        Color(hex: "#af7aa1"),
        Color(hex: "#9c755f"),
        Color(hex: "#8dd3c7"),
        Color(hex: "#80b1d3"),
        Color(hex: "#b3de69"),
        Color(hex: "#bc80bd"),
        Color(hex: "#ffed6f"),
        Color(hex: "#66c2a5"),
        Color(hex: "#fc8d62"),
        Color(hex: "#8da0cb"),
        Color(hex: "#e78ac3"),
        Color(hex: "#a6d854"),
        Color(hex: "#ffd92f"),
        Color(hex: "#e5c494"),
        Color(hex: "#999999"),
        Color(hex: "#377eb8"),
        Color(hex: "#4daf4a"),
        Color(hex: "#984ea3"),
        Color(hex: "#a65628"),
        Color(hex: "#f781bf"),
        Color(hex: "#a6cee3"),
        Color(hex: "#b2df8a"),
        Color(hex: "#fb9a99"),
        Color(hex: "#e31a1c"),
        Color(hex: "#fdbf6f"),
        Color(hex: "#6a3d9a"),
        Color(hex: "#666666"),
        Color(hex: "#7fc97f"),
        Color(hex: "#beaed4"),
        Color(hex: "#fdc086"),
        Color(hex: "#386cb0"),
        Color(hex: "#f0027f"),
        Color(hex: "#bf5b17"),
        Color(hex: "#17becf"),
        Color(hex: "#1f77b4"),
        Color(hex: "#ff7f0e"),
        Color(hex: "#2ca02c"),
        Color(hex: "#d62728"),
        Color(hex: "#9467bd"),
        Color(hex: "#8c564b"),
        Color(hex: "#e377c2"),
        Color(hex: "#7f7f7f"),
        Color(hex: "#bcbd22")
    ]

    static public var presetColors: [Color] = {
        originalPresetColors.shuffled()
    }()

    static private var labelColorMap: [String: [Color]] = [:]
    static private var usedColors: [Color] = []
    static private var unusedColors = presetColors

    static public func consistentColors(labels: [String]) -> [Color] {
        var chosenColors: [Color] = labels.map { _ in Color.originalPresetColors.shuffled().first! }
        var chosenColorsMap: [Color: Bool] = [:]
        var unassignedLabels: [(label: String, index: Int)] = []
        for (index, label) in labels.enumerated() {
            if let colors = labelColorMap[label] {
                // find assign records
                var success = false
                for color in colors where chosenColorsMap[color] == nil {
                    // color for label
                    chosenColors[index] = color
                    chosenColorsMap[color] = true
                    success = true
                    break
                }

                if !success {
                    // choose a new color! But LATER!
                    unassignedLabels.append((label: label, index: index))
                }
            } else {
                // never assigned, assign a new color! But LATER!
                unassignedLabels.append((label: label, index: index))
            }
        }

        for (label, index) in unassignedLabels {
            if let unusedColor = unusedColors.first {
                usedColors.append(unusedColor)
                unusedColors.removeFirst()
                if labelColorMap[label] == nil {
                    labelColorMap[label] = []
                }
                labelColorMap[label]!.append(unusedColor)
                chosenColors[index] = unusedColor
                chosenColorsMap[unusedColor] = true
            } else {
                for color in presetColors.shuffled() where chosenColorsMap[color] == nil {
                    if labelColorMap[label] == nil {
                        labelColorMap[label] = []
                    }
                    labelColorMap[label]!.append(color)
                    chosenColors[index] = color
                    chosenColorsMap[color] = true
                    break
                }
            }
        }

        return chosenColors
    }
}

struct ColorsPreviewView: View {
    var colors: [Color] = Color.originalPresetColors

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(colors, id: \.self) { color in
                    color
                        .frame(height: 30)
                        .overlay(Text("\(color.components.red), \(color.components.green), \(color.components.blue)"))
                }
            }
        }
    }
}

struct ColorsPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ColorsPreviewView()
    }
}
