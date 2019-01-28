//
//  Cuboid.swift
//  PrintCreator
//
//  Created by Sahir Shahryar on 7/20/18.
//  Copyright © 2018 Sahir Shahryar. All rights reserved.
//

import Foundation

public class Cuboid: CustomStringConvertible {

    public let min: Vector
    public let max: Vector

    public var description: String {
        return "min = \(min); max = \(max)"
    }

    public init(min: Vector, max: Vector) {
        let trueMin = Vector.min(min, max)
        let trueMax = Vector.max(min, max)

        self.min = trueMin
        self.max = trueMax
    }

    public func contains(_ pt: Vector) -> Bool {
        return pt.x.within(min.x, max.x)
            && pt.y.within(min.y, max.y)
            && pt.z.within(min.z, max.z)
    }

}
