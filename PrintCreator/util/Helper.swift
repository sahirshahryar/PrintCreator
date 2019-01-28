/*
 * This file is part of PrintCreator, licensed under the MIT License (MIT).
 *
 * Copyright (c) Sahir Shahryar <https://github.com/sahirshahryar>
 *                              <sahirshahryar@gmail.com>
 *
 * This software is not intended to be sold.
 *
 * MIT LICENSE:
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

/**
 * @author  Sahir Shahryar
 * @since   Monday, June 4,  2018
 * @version 1.0.0
 */
import Foundation
import UIKit

public let DEBUG = true


/**
 * Performs exponentiation on two `Int16` values, returning another `Int16`.
 *
 * - parameters:
 *     - base:  (`Int16`) the base to multiply.
 *     - power: (`Int16`) the power to which `base` is being multiplied.
 *
 * - returns:
 * The result `(base)^(power)`, if the symbol `^` represents exponentiation.
 */
public func int16Pow(_ base: Int16, power: Int16) -> Int16 {
    if power == 0 {
        return 1
    }
    
    var answer = base
    for _ in 1 ..< power {
        answer *= base
    }
    
    return answer
}

public func debug(_ statement: String = "") {
    if DEBUG {
        print(statement)
    }
}

public func nanos(ms: UInt64) -> UInt64 {
    return 1_000_000 * ms
}

/**
 *
 */
public func devariadize(_ input: Any...) -> [AnyObject] {
    var result = [AnyObject]()
    for elem in input {
        guard let array = elem as? Array<Any> else {
            result.append(elem as AnyObject)
            continue
        }

        for internalElem in array {
            result.append(internalElem as AnyObject)
        }
    }

    return result
}

/**
 *
 */
public func frequencyMap<T, P>(objects: [T], property: (T) -> P) -> [P: Int] {
    var result = [P: Int]()
    
    for object in objects {
        let objProperty = property(object)
        result[objProperty] = (result[objProperty] ?? 0) + 1
    }
    
    return result
}


/**
 *
 */
public func frequencyMapIterator<P>(map: [P: Int]) -> [P] {
    var result = [P]()
    
    while result.count < map.keys.count {
        var max = 0
        var maxValue: P? = nil
        for (prop, freq) in map {
            if freq > max {
                if !result.contains(prop) {
                    max = freq
                    maxValue = prop
                }
            }
        }
        
        // This should not happen!
        if maxValue == nil {
            continue
        }
        
        result.append(maxValue!)
    }
    
    return result
}


/**
 *
 */
public func isTablet() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}
