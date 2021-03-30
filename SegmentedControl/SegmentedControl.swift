//
//  SegmentedControl.swift
//  SegmentedControl
//
//  Created by John on 26/03/2021.
//

import Cocoa

/**
 * Requirements:
 *
 * Animated (layer backed)
 * Title per segment.
 * Support light & dark modes.
 * Compatible with Catalina 10.15.
 * No need for customisation (font etc).
 *
 * Optional:
 * Images
 * Tint colour
 *
 * Behaviour:
 * Mouse-down on unselected segment animates to/from gray.
 * Mouse-up in unselected segment moves selection (animated).
 * Mouse-down on selected segment "pushes" selection (button).
 * Mouse-drag on selected segment moves selection (animated).
 */

public class SegmentedControl: NSControl {

    private enum Metrics {
        static let standardHeight: CGFloat = 24
        static let cornerRadius: CGFloat = 6
        static let edgeInset: CGFloat = 1
        static let segmentPadding: CGFloat = 5
        static let separatorWidth: CGFloat = 1
    }

    /**
     * Number of segments in the control.
     */
    public var count: Int {
        return segments.count
    }

    /**
     * Get or set the selected segment index.
     * Updates to selectedSegmentIndex are always animated, unless explicitly disabled.
     * Returns nil if no segment is selected.
     */
    public var selectedSegmentIndex: Int? {
        get {
            segments.firstIndex { $0.isSelected }
        }
        set {
            CATransaction.withAnimation(duration: 0.3, timing: .easeOut) {
                for idx in 0..<segments.count {
                    segments[idx].isSelected = (idx == newValue)
                }
                updateSeparators()
                layoutSelectionHighlight()
            }
        }
    }

    @IBInspectable
    public var tintColor: NSColor? {
        didSet {
            updateSegments()
            updateSelectionHighlightColor()
        }
    }

    @IBInspectable
    public var isMomentary: Bool = false {
        didSet {
            updateSegments()
            updateSeparators()
            layoutSelectionHighlight()
        }
    }

    // Indicates whether the control attempts to adjust segment widths based on their content widths.
    @IBInspectable
    public var apportionsSegmentWidthsByContent: Bool = false {
        didSet {
            needsLayout = true
        }
    }

    private var segments: [SegmentLayer] {
        return segmentContainer.sublayers as? [SegmentLayer] ?? []
        // let sublayers = segmentContainer.sublayers ?? []
        // return sublayers.compactMap { $0 as? SegmentLayer }
    }

    private var separators: [SegmentSeparator] {
        return separatorContainer.sublayers as? [SegmentSeparator] ?? []
        // let sublayers = separatorContainer.sublayers ?? []
        // return sublayers.compactMap { $0 as? SegmentSeparator }
    }

    /**
     * segmentContainer contains our SegmentLayer layers.
     * This layer sits above the control's layer, which contains the selectionHighlight and separator items.
     */
    private var segmentContainer = CALayer()

    private var separatorContainer = CALayer()

    private var selectionHighlight: CALayer = {
        let layer = CALayer()
        layer.cornerRadius = Metrics.cornerRadius - 1
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0, height: -3)
        return layer
    }()

    public override var fittingSize: NSSize {
        // TODO
        return super.fittingSize
    }

    public override var intrinsicContentSize: NSSize {
        // TODO
        return super.intrinsicContentSize
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        wantsLayer = true

        layer?.cornerRadius = Metrics.cornerRadius
        layer?.borderColor = nil

        layer?.addSublayer(selectionHighlight)
        layer?.addSublayer(segmentContainer)
        layer?.addSublayer(separatorContainer)
    }

    public func setSelectedSegmentIndex(_ idx: Int, animated: Bool) {
        guard idx != self.selectedSegmentIndex else {
            return
        }

        if !animated {
            CATransaction.withoutAnimation {
                self.selectedSegmentIndex = idx
            }
        } else {
            self.selectedSegmentIndex = idx
        }
    }

    public func insertSegment(title: String, at idx: Int) {
        let segment = SegmentLayer()
        segment.title = title
        segment.isSelected = self.count == 0
        segmentContainer.insertSublayer(segment, at: UInt32(idx))

        let separator = SegmentSeparator()
        separatorContainer.insertSublayer(separator, at: UInt32(idx))

        updateSegments()
        updateSeparators()
    }

    public func removeSegment(at idx: Int) {
        segmentContainer.sublayers?[idx].removeFromSuperlayer()
        separatorContainer.sublayers?[idx].removeFromSuperlayer()
        updateSeparators()
    }

    public func removeAllSegments() {
        segmentContainer.sublayers?.forEach { $0.removeFromSuperlayer() }
        separatorContainer.sublayers?.forEach { $0.removeFromSuperlayer() }
        selectionHighlight.isHidden = true
    }

    public func setTitle(_ title: String, forSegment idx: Int) {
        segments[idx].title = title
    }

    public func titleForSegment(_ idx: Int) -> String? {
        return segments[idx].title
    }

    public func setImage(_ image: NSImage, forSegment idx: Int) {
        segments[idx].image = image
    }

    public func imageForSegment(_ idx: Int) -> NSImage? {
        return segments[idx].image
    }

    public func setWidth(_ width: CGFloat, forSegment idx: Int) {
        segments[idx].fixedWidth = width
    }

    public func widthForSegment(_ idx: Int) -> CGFloat {
        return segments[idx].fixedWidth
    }

    public override func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()

        guard let contentsScale = layer?.contentsScale else {
            return
        }

        selectionHighlight.contentsScale = contentsScale

        segmentContainer.sublayers?.forEach {
            $0.contentsScale = contentsScale
        }
    }

    /**
     * Note: Cocoa will set the correct (current) NSAppearance when calling updateLayer()
     * This means we can obtain the NSColors.
     */
    public override func updateLayer() {
        super.updateLayer()

        // quaternaryLabelColor is a good match for aqua and dark appearance modes.
        // controlBackgroundColor works for dark, but not for aqua (where it is white).
        layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor

        updateSelectionHighlightColor()

        segments.forEach { $0.updateAppearance() }
        separators.forEach { $0.updateAppearance() }
    }

    public override func layout() {
        super.layout()

        separatorContainer.frame = bounds
        segmentContainer.frame = bounds

        layoutSegments()
        layoutSelectionHighlight()
    }

    private func layoutSegments() {
        let count = self.count

        guard count > 0 else {
            return
        }

        // If any segments have fixed widths, then reduce "flexible" width by that amount:
        var fixedCount: Int = 0
        var fixedWidth: CGFloat = 0
        var contentWidth: CGFloat = 0

        let segments = self.segments

        for segment in segments {
            if segment.fixedWidth > 0 {
                fixedWidth += segment.fixedWidth
                fixedCount += 1
            } else {
                contentWidth += segment.preferredFrameSize().width
            }
        }

        var contentBounds = bounds.insetBy(dx: Metrics.edgeInset, dy: Metrics.edgeInset)
        contentBounds.size.width -= Metrics.segmentPadding * CGFloat(count - 1)
        var segmentWidth: CGFloat = 0

        if fixedCount < count {
            let nonFixedCount = count - fixedCount
            if apportionsSegmentWidthsByContent {
                // Increase section width if segments do not take up remaining flexibleWidth.
                // This may be negative if available width will not accommodate all content.
                let unusedWidth = contentBounds.size.width - contentWidth - fixedWidth
                segmentWidth = unusedWidth / CGFloat(nonFixedCount)
            } else {
                let flexibleWidth = contentBounds.size.width - fixedWidth
                segmentWidth = max(0, flexibleWidth / CGFloat(nonFixedCount))
            }
        }

        var frame = contentBounds;
        let separators = self.separators

        for (idx, segment) in segments.enumerated() {
            if segment.fixedWidth > 0 {
                frame.size.width = segment.fixedWidth
            } else if apportionsSegmentWidthsByContent {
                // Any unused width is added via segmentWidth:
                frame.size.width = segment.preferredFrameSize().width + segmentWidth
            } else {
                frame.size.width = segmentWidth
            }
            segment.frame = frame.rounded
            separators[idx].frame = separatorFrame(for: frame).rounded

            frame.origin.x = frame.maxX + Metrics.segmentPadding
        }
    }

    private func layoutSelectionHighlight() {
        if let idx = selectedSegmentIndex, !isMomentary {
            selectionHighlight.isHidden = false
            selectionHighlight.frame = segments[idx].frame
        } else {
            selectionHighlight.isHidden = true
        }
    }

    private func separatorFrame(for segmentFrame: CGRect) -> CGRect {
        var frame = segmentFrame
        frame.origin.x = frame.maxX
        frame.size.width = Metrics.segmentPadding
        return frame
    }

    private func updateSegments() {
        for segment in segments {
            segment.isMomentary = isMomentary
            segment.tintColor = tintColor
        }
    }

    private func updateSeparators() {
        let selectedIndex = selectedSegmentIndex ?? NSNotFound
        let count = self.count

        for (idx, separator) in self.separators.enumerated() {
            if isMomentary {
                separator.isHidden = (idx == count - 1)
            } else {
                separator.isHidden = (idx == count - 1 || idx == selectedIndex - 1 || idx == selectedIndex)
            }
        }
    }

    private func updateSelectionHighlightColor() {
        selectionHighlight.backgroundColor = (tintColor ?? NSColor.controlColor).cgColor
    }

}

extension SegmentedControl {

    /**
     * SegmentLayer handles the segment appearance.
     */
    private class SegmentLayer: CALayer {

        var title: String? {
            didSet {
                updateAppearance()
            }
        }

        var image: NSImage? {
            didSet {
                updateAppearance()
            }
        }

        var isSelected = false {
            didSet {
                updateAppearance()
            }
        }

        var isMomentary = false {
            didSet {
                updateAppearance()
            }
        }

        var tintColor: NSColor? {
            didSet {
                updateAppearance()
            }
        }

        /**
         * Segment is auto-sized if width is zero. Otherwise the width is fixed.
         */
        var fixedWidth: CGFloat = 0.0

        private let textLayer: CATextLayer = {
            let layer = CATextLayer()
            layer.fontSize = NSFont.systemFontSize
            layer.alignmentMode = .center
            layer.truncationMode = .end
            return layer
        }()

        override init() {
            super.init()
            commonInit()
        }

        override init(layer: Any) {
            super.init(layer: layer)
            // TODO: Copy layer's properties (for presentation layer).
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit()
        }

        private func commonInit() {
            // TODO: scale to fit image...
            contentsGravity = .resizeAspect
            contentsRect = CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8)

            addSublayer(textLayer)
            updateAppearance()
        }

        func updateAppearance() {
            if let image = self.image {
                contents = image
                textLayer.isHidden = true
            } else {
                contents = nil
                textLayer.isHidden = false
                textLayer.string = self.title

                if isSelected && !isMomentary {
                    textLayer.font = NSFont.systemFont(ofSize: textLayer.fontSize, weight: .medium)
                    textLayer.foregroundColor = (tintColor?.contrastingTextColor ?? NSColor.textColor).cgColor
                } else {
                    // Could use labelFont(ofSize:) here, but for consistency with the bold style,
                    // we are using systemFont(ofSize:).
                    textLayer.font = NSFont.systemFont(ofSize: textLayer.fontSize)
                    textLayer.foregroundColor = NSColor.textColor.cgColor
                }
            }
        }

        override func layoutSublayers() {
            super.layoutSublayers()

            guard let font = textLayer.font,
                  let string = textLayer.string as? NSString,
                  string.length > 0 else {
                return
            }

            let textSize = string.size(withAttributes: [.font: font])

            var frame = bounds
            frame.origin.y = (bounds.height - textSize.height) / 2 + 1
            frame.size.height = textSize.height
            textLayer.frame = frame
        }

        override var contentsScale: CGFloat {
            didSet {
                textLayer.contentsScale = contentsScale
            }
        }

        override func preferredFrameSize() -> CGSize {
            var size = CGSize(width: 0, height: superlayer?.bounds.size.height ?? 0)
            if (fixedWidth > 0) {
                size.width = fixedWidth
            } else if let title = self.title,
                      let font = textLayer.font {
                size.width = title.size(withAttributes: [.font: font]).width + Metrics.segmentPadding * 2
            }
            return size
        }

    }

}

extension SegmentedControl {

    private class SegmentSeparator: CALayer {

        override init() {
            super.init()
            commonInit()
        }

        override init(layer: Any) {
            super.init(layer: layer)
            commonInit()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit()
        }

        private func commonInit() {
            // The separator bar is drawn using a separate sub-layer, centered in SegmentSeparator
            let separator = CALayer()
            addSublayer(separator)
            updateAppearance()
        }

        func updateAppearance() {
            sublayers?.first?.backgroundColor = NSColor.separatorColor.cgColor
        }

        override func layoutSublayers() {
            super.layoutSublayers()

            var frame = bounds.insetBy(dx: 0, dy: floor(bounds.height * 0.2))
            frame.size.width = Metrics.separatorWidth
            frame.origin.x = (bounds.width - frame.size.width) / 2.0
            sublayers?.first?.frame = frame.rounded
        }

    }

}

extension CGRect {

    var rounded: CGRect {
        CGRect(x: floor(origin.x),
               y: floor(origin.y),
               width: ceil(size.width),
               height: ceil(size.height))
    }

}
