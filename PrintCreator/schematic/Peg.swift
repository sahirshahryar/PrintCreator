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

/**
 * Represents a location where a peg can be inserted into a block.
 *
 * @author  Sahir Shahryar
 * @since   Monday, June 4, 2018
 * @version 1.0.0
 */
public class Peg {
   
    /**
     * The physical location of this peg relative to the `BlockFace` it exists on.
     */
    private let location: Vector
    
    
    /**
     * Initializes this `Peg`, with the position being charted on a plane perpendicular
     * to the `Quaternion` that represents the rotation of the parent `BlockFace`.
     *
     * - parameters:
     *     - x: `(Double)` the x-coordinate of the center of this peg slot, relative to
     *          the center of the plane charted by 
     */
    public init(x: Double, y: Double, scaleTo: Double) {
        self.location = Vector(x / scaleTo, y / scaleTo, 0)
    }
    
    
    /**
     *
     */
    public func getLocation() -> Vector {
        return self.location
    }
    
}
