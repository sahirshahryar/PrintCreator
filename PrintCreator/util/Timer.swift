//
//  Timer.swift
//  PrintCreator
//
//  Created by Sahir Shahryar on 7/8/18.
//  Copyright © 2018 Sahir Shahryar. All rights reserved.
//

import Foundation

public class Timer {

    private var start: UInt64?

    public init(wait: Bool = false) {
        if !wait {
            start = mach_absolute_time()
        }
    }

    public func go() {
        start = mach_absolute_time()
    }

    public func current() -> UInt64 {
        return mach_absolute_time() - start!
    }

    public func report(_ label: String = "") {
        let time = current()
        if label == "" {
            debug("\(time) ns")
        } else {
            debug("\(label): \(time) ns")
        }
    }

}
