//
//  ViewController.swift
//  SegmentedControl
//
//  Created by John on 26/03/2021.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var defaultControl: SegmentedControl?

    @IBOutlet weak var proportionalControl: SegmentedControl?

    @IBOutlet weak var tintedControl: SegmentedControl?

    @IBOutlet weak var imageControl: SegmentedControl?

    @IBOutlet weak var momentaryControl: SegmentedControl?

    @IBOutlet weak var statusLabel: NSTextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        defaultControl?.insertSegment(title: "First", at: 0)
        defaultControl?.insertSegment(title: "Second", at: 1)
        defaultControl?.insertSegment(title: "Third", at: 2)

        proportionalControl?.insertSegment(title: "First", at: 0)
        proportionalControl?.insertSegment(title: "Second Title", at: 1)
        proportionalControl?.insertSegment(title: "Third", at: 2)
        proportionalControl?.insertSegment(title: "Fourth Title", at: 3)

        tintedControl?.insertSegment(title: "First", at: 0)
        tintedControl?.insertSegment(title: "Second", at: 1)
        tintedControl?.insertSegment(title: "Third", at: 2)

        imageControl?.insertSegment(image: NSImage(named: NSImage.homeTemplateName)!, at: 0)
        imageControl?.insertSegment(image: NSImage(named: NSImage.iconViewTemplateName)!, at: 1)
        imageControl?.insertSegment(image: NSImage(named: NSImage.lockLockedTemplateName)!, at: 2)
        imageControl?.insertSegment(image: NSImage(named: NSImage.folderName)!, at: 3)

        momentaryControl?.insertSegment(image: NSImage(named: NSImage.addTemplateName)!, at: 0)
        momentaryControl?.insertSegment(image: NSImage(named: NSImage.actionTemplateName)!, at: 1)
        momentaryControl?.insertSegment(image: NSImage(named: NSImage.bookmarksTemplateName)!, at: 2)
        momentaryControl?.insertSegment(image: NSImage(named: NSImage.refreshTemplateName)!, at: 3)
        momentaryControl?.insertSegment(title: "More", at: 4)
    }

    @IBAction func toggleSelectedIndex(_ sender: Any?) {
        let selectedIndex = defaultControl?.selectedSegmentIndex ?? 0
        let count = defaultControl?.count ?? 0
        let nextIndex = selectedIndex < count - 1 ? selectedIndex + 1 : 0

        defaultControl?.setSelectedSegmentIndex(nextIndex, animated: true)

        defaultSegmentDidChange(defaultControl)
    }

    @IBAction func defaultSegmentDidChange(_ sender: SegmentedControl?) {
        let defaultText = "No Selected Segment"

        if let segment = sender?.selectedSegmentIndex,
           let title = sender?.titleForSegment(segment) {
            self.statusLabel?.stringValue = "\(segment): \(title)"
        } else {
            self.statusLabel?.stringValue = defaultText
        }
    }

    @IBAction func momentaryControlAction(_ sender: SegmentedControl?) {
        print("momentaryControlAction:", sender?.selectedSegmentIndex ?? "nil")
    }

}

