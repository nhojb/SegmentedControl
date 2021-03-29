//
//  ViewController.swift
//  SegmentedControl
//
//  Created by John on 26/03/2021.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var segmentedControl: SegmentedControl?

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl?.insertSegment(title: "First", at: 0)
        segmentedControl?.insertSegment(title: "Second", at: 1)
        segmentedControl?.insertSegment(title: "Third", at: 2)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

