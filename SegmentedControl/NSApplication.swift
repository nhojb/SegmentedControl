//
//  NSApplication.swift
//  SegmentedControl
//
//  Created by John on 30/03/2021.
//

import Cocoa

extension NSApplication {

    /**
     * Perform block with the application's effectiveAppearance.
     * For example this allows fetching the correct named color from a NSColor e.g.
     *
     * NSApp.withEffectiveAppearance {
     *     appearanceAwareColor = NSColor.textColor.cgColor
     * }
     */
    func withEffectiveAppearance(_ block: () -> Void) {
        if #available(*, macOS 11) {
            effectiveAppearance.performAsCurrentDrawingAppearance(block)
        } else {
            let previousAppearance = NSAppearance.current
            NSAppearance.current = effectiveAppearance
            block()
            NSAppearance.current = previousAppearance
        }
    }

}
