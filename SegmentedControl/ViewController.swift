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

    @IBAction func toggleSelectedIndex(_ sender: Any?) {
        let selectedIndex = self.segmentedControl?.selectedSegmentIndex ?? 0
        let count = self.segmentedControl?.count ?? 0
        let nextIndex = selectedIndex < count - 1 ? selectedIndex + 1 : 0

        self.segmentedControl?.setSelectedSegmentIndex(nextIndex, animated: true)
    }

}

