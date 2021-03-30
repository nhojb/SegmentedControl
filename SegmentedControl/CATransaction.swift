//
//  CATransaction.swift
//  SegmentedControl
//
//  Created by John on 30/03/2021.
//

import Cocoa

extension CATransaction {

    class func withAnimation(duration: TimeInterval, timing: CAMediaTimingFunctionName? = nil, _ actions: () -> Void, _ completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        if let functionName = timing {
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: functionName))
        }
        CATransaction.setCompletionBlock(completion)
        actions()
        CATransaction.commit()
    }

    class func withoutAnimation(_ actions: () -> Void, _ completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock(completion)
        actions()
        CATransaction.commit()
    }

}

