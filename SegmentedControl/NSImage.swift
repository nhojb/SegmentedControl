//
//  NSImage.swift
//  SegmentedControl
//
//  Created by John on 31/03/2021.
//

import Cocoa

extension NSImage {

    func image(withTintColor tintColor: NSColor) -> NSImage {
        guard isTemplate else {
            return self
        }

        guard let copiedImage = self.copy() as? NSImage else {
            return self
        }

        copiedImage.lockFocus()
        tintColor.set()
        let imageBounds = CGRect(x: 0, y: 0, width: copiedImage.size.width, height: copiedImage.size.height)
        imageBounds.fill(using: .sourceAtop)
        copiedImage.unlockFocus()

        copiedImage.isTemplate = false
        return copiedImage
    }

}
