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
import SceneKit

public typealias Vector = SCNVector3
public typealias Quaternion = SCNVector4

/**
 * It turns out that `SCNVector3` is actually *really* barebones, with just `x`, `y`, and
 * `z` being its only components. This extension aims to make `SCNVector3` a little more
 * useful.
 *
 * - author:  Sahir Shahryar
 * - since:   Wednesday, June 6, 2018
 * - version: 1.0.0
 */
public extension Vector {

    /**
     *
     */
    public static let ZERO = Vector(0, 0, 0)


    /**
     *
     */
    public static let UNIT = Vector(1, 1, 1)


    /**
     *
     */
    public static let I = Vector(1, 0, 0)


    /**
     *
     */
    public static let J = Vector(0, 1, 0)


    /**
     *
     */
    public static let K = Vector(0, 0, 1)


    /**
     * Converts this `Vector` to a `Quaternion`.
     *
     * - parameter theta: `(Double)` the new `w`-component of the resultant `Quaternion`.
     *
     * - returns: `(Quaternion)` a `Quaternion` with components `(x, y, z, theta)`.
     */
    public func to4D(theta: Double) -> Quaternion {
        return Quaternion(self.x, self.y, self.z, Float(theta))
    }
    
    
    /**
     * Returns the magnitude of this vector.
     *
     * - returns: `(Double)` the length the line segment between the origin `(0, 0, 0)`
     *            and the point `(x, y, z)` in Cartesian space.
     */
    public func magnitude() -> Double {
        return sqrt(Double(pow(self.x, 2) + pow(self.y, 2) + pow(self.z, 2)))
    }
    
    
    /**
     * Determines if this vector is a zero vector.
     */
    public func isZero() -> Bool {
        return self.x == 0
            && self.y == 0
            && self.z == 0
    }


    /**
     *
     */
    public func normalized() -> Vector {
        if self.isZero() {
            return Vector(0, 0, 0)
        }
        
        return self / self.magnitude()
    }


    /**
     *
     */
    public func cross(_ vec: Vector) -> Vector {
        return Vector(
            self.y * vec.z - self.z * vec.y,
            self.z * vec.x - self.x * vec.z,
            self.x * vec.y - self.y * vec.x
        )
    }


    /**
     *
     */
    public static func + (left: Vector, right: Vector) -> Vector {
        return Vector(left.x + right.x,
                          left.y + right.y,
                          left.z + right.z)
    }


    /**
     *
     */
    public static func - (left: Vector, right: Vector) -> Vector {
        return Vector(left.x - right.x,
                          left.y - right.y,
                          left.z - right.z)
    }


    /**
     *
     */
    public static func * (coeff: Double, vec: Vector) -> Vector {
        return Vector(Float(coeff) * vec.x,
                          Float(coeff) * vec.y,
                          Float(coeff) * vec.z)
    }


    /**
     *
     */
    public static func * (vec: Vector, coeff: Double) -> Vector {
        return coeff * vec
    }


    /**
     *
     */
    public static func * (left: Vector, right: Vector) -> Double {
        return Double(left.x * right.x
                    + left.y * right.y
                    + left.z * right.z)
    }


    /**
     *
     */
    public static func / (vec: Vector, div: Double) -> Vector {
        return Vector(vec.x / Float(div),
                          vec.y / Float(div),
                          vec.z / Float(div))
    }


    /**
     *
     */
    public static prefix func - (vec: Vector) -> Vector {
        return Vector(-vec.x, -vec.y, -vec.z)
    }

    public static func == (left: Vector, right: Vector) -> Bool {
        return left.x == right.x
            && left.y == right.y
            && left.z == right.z
    }


    public static func min(_ a: Vector, _ b: Vector) -> Vector {
        return Vector(Swift.min(a.x, b.x), Swift.min(a.y, b.y), Swift.min(a.z, b.z))
    }

    public static func max(_ a: Vector, _ b: Vector) -> Vector {
        return Vector(Swift.max(a.x, b.x), Swift.max(a.y, b.y), Swift.max(a.z, b.z))
    }


    
    /**
     * Rotates this vector around a quaternion via an intermediary step in the
     * derivation of Rodrigues' formula. Basically, this formula shifts the current
     * vector around the origin (with components equivalent to the distance from the
     * specified quaternion), rotates around *that*, then shifts the vector back up
     * by the same amount that was subtracted.
     *
     * - parameter by: `(Quaternion)` the `Quaternion` to rotate around. The plane used
     *                 will be the plane perpendicular to the 3D vector formed by the
     *                 quaternion's `x`-, `y`-, and `z`-coordinates, and this vector will
     *                 be rotated by `w` radians.
     *
     * - returns: `(Vector)` this vector, after it has been rotated around the given
     *            plane at the given angle, or a vector with identical components if the
     *            3D-vector portion of `by` is a zero vector.
     *
     * See [this page](http://electroncastle.com/wp/?p=39) at Electron Castle for more
     * information.
     */
    public func rotate(by quat: Quaternion) -> Vector {
        if !quat.to3D().isZero() {
            let theta = quat.w
            
            /**
             * See the article linked above to understand what these variables mean.
             *
             * v    = self
             * n    = axis
             * v_p  = projection
             * v_r  = projectedVector
             * w    = perpendicular
             * v_rr = projectedRotation
             * u    = (return statement)
             */
            let axis = quat.to3D().normalized()
            let projection = Double(axis * self) * axis
            
            let projectedVector = self - projection
            let perpendicular = axis.cross(self)
            
            let projectedRotation = (projectedVector * Double(cos(theta)))
                                  + (perpendicular * Double(sin(theta)))
            
            return projectedRotation + projection
        }

        /**
         * The vector provided was a zero vector, which means it can't contain any
         * useful rotational information.
         */
        else {
            return Vector(self.x, self.y, self.z)
        }
    }

    public func rewind(origin: Vector, distance: Float) -> Vector {
        // return self + (Double(distance) * (origin - self).normalized())

        return (Double(1 - distance) * (origin - self).normalized())
    }

    public func projectXZ() -> OrderedPair {
        return OrderedPair(Double(self.x), Double(self.z))
    }

    public func projectXY() -> OrderedPair {
        return OrderedPair(Double(self.x), Double(self.y))
    }

    public func yaw(relativeTo: Vector) -> Float {
        let subtraction = (self - relativeTo).normalized()
        return atan2f(subtraction.x, subtraction.z)
    }

    public func pitch(relativeTo: Vector) -> Float {
        let subtraction = (self - relativeTo).normalized().projectXY().normalized()
        return asin(Float(subtraction.y))
    }

}


/**
 *
 */
public extension Quaternion {
    
    public func to3D() -> Vector {
        return Vector(self.x, self.y, self.z)
    }
    
    public static func + (left: Quaternion, right: Quaternion) -> Quaternion {
        return Quaternion(left.x + right.x,
                          left.y + right.y,
                          left.z + right.z,
                          left.w + right.w)
    }
    
}


public class OrderedPair {

    var x: Double, y: Double

    public init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }

    public static func * (left: Double, right: OrderedPair) -> OrderedPair {
        return OrderedPair(left * right.x, left * right.y)
    }

    public static func / (left: OrderedPair, right: Double) -> OrderedPair {
        return (1 / right) * left
    }

    public func length() -> Double {
        return sqrt(pow(x, 2) + pow(y, 2))
    }

    public func normalized() -> OrderedPair {
        return self / length()
    }


}
