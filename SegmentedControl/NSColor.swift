//
//  NSColor.swift
//  SegmentedControl
//
//  Created by John on 30/03/2021.
//

import Cocoa

extension NSColor {

    private struct Components {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
    }

    private func components() -> Components {
        var result = Components()
        self.getRed(&result.r, green: &result.g, blue: &result.b, alpha: &result.a)
        return result
    }

    var contrastingTextColor: NSColor {
        if self == NSColor.clear {
            return .textColor
        }

        guard let c1 = self.usingColorSpace(.deviceRGB) else {
            return .textColor
        }

        let rgbColor = c1.components()

        // Counting the perceptive luminance - human eye favors green color...
        let avgGray: CGFloat = 1 - (0.299 * rgbColor.r + 0.587 * rgbColor.g + 0.114 * rgbColor.b)
        return avgGray > 0.5 ? .white : .black
    }

}
