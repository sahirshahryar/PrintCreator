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
import Foundation
import UIKit


/**
 * Okay, so we're now quite clearly into the territory of things that Java wouldn't even
 * dream of let you doing.
 *
 * - author:  Sahir Shahryar
 * - since:   Monday, June 11, 2018
 * - version: 1.0.0
 */
public extension Int {


    /**
     *
     */
    public func pluralize(zero: String? = nil,
                          one: String,
                          plural: String,
                          blanks: Any...) -> String {
        let trueZero = zero ?? plural
        let adjustedVarargs = devariadize(blanks)

        switch self {
        case 0:
            return trueZero.localizeNonVariadic(adjustedVarargs)
        case 1:
            return one.localizeNonVariadic(adjustedVarargs)
        default:
            return plural.localizeNonVariadic(adjustedVarargs)
        }
    }

    public func getNiceNumber() -> String {
        let result = "numbers.\(self)".localize()
        return result == "numbers.\(self)" ? self.format() : result
    }

    public func format() -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale.current

        return formatter.string(from: NSNumber(value: self))!
    }


    /**
     *
     */
    public func constrainTo(_ min: Int, _ max: Int) -> Int {
        if self < min {
            return min
        } else if self > max {
            return max
        }
        
        return self
    }


    /**
     *
     */
    public func within(_ min: Int, _ max: Int) -> Bool {
        return self >= min && self < max
    }


    /**
     *
     */
    public func anyOf(_ values: [Int]) -> Bool {
        for value in values {
            if self == value {
                return true
            }
        }
        
        return false
    }
    

    /**
     *
     */
    public func noneOf(_ values: [Int]) -> Bool {
        for value in values {
            if self == value {
                return false
            }
        }
        
        return true
    }
    
}


/**
 *
 */
public extension CGFloat {

    public func constrainTo(_ min: CGFloat, _ max: CGFloat) -> CGFloat {
        if self < min {
            return min
        } else if self > max {
            return max
        }

        return self
    }

    public func signum() -> Int {
        return self == 0 ? 0 : (self > 0 ? 1 : -1)
    }

}


public extension Float {

    public func within(_ min: Float, _ max: Float) -> Bool {
        return self >= min && self <= max
    }

}
