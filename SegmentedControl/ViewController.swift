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

    override func viewDidLoad() {
        super.viewDidLoad()

        defaultControl?.insertSegment(title: "First", at: 0)
        defaultControl?.insertSegment(title: "Second", at: 1)
        defaultControl?.insertSegment(title: "Third", at: 2)

        proportionalControl?.insertSegment(title: "First", at: 0)
        proportionalControl?.insertSegment(title: "Second Title", at: 1)
        proportionalControl?.insertSegment(title: "Third", at: 2)

        tintedControl?.insertSegment(title: "First", at: 0)
        tintedControl?.insertSegment(title: "Second", at: 1)
        tintedControl?.insertSegment(title: "Third", at: 2)

    }

    @IBAction func toggleSelectedIndex(_ sender: Any?) {
        let selectedIndex = proportionalControl?.selectedSegmentIndex ?? 0
        let count = proportionalControl?.count ?? 0
        let nextIndex = selectedIndex < count - 1 ? selectedIndex + 1 : 0

        proportionalControl?.setSelectedSegmentIndex(nextIndex, animated: true)
    }

}

