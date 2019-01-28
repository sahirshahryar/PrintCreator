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

/**
 * Represents the location of a `Block` relative to the root block in a model. Since a
 * 3D-coordinate system is a bit too simple for a modeling system that allows for
 * non-cubical blocks, we use relative positioning instead of absolute positioning. This
 * means that 
 *
 * - author:  Sahir Shahryar
 * - since:   Sunday, May 27, 2018
 * - version: 1.0.0
 */
public class BlockPath: Hashable, CustomStringConvertible {
    
    
    /**
     * This is a `BlockPath` that represents the root of a model.
     */
    public static let ROOT_PATH = BlockPath([])
    
    
    /**
     * The hash value of this path, inherited from the `Hashable` protocol. Present so
     * that `BlockPath` objects can be used as keys in a dictionary.
     *
     * The hash value of a BlockPath is simply the hash value of its path components
     * joined together by slashes. So, for example, if the path is "up" -> "left" ->
     * "left", then the hash value is the hash of "up/left/left" (-1855814959586008700).
     */
    public var hashValue: Int {
        return self.hashPath().hashValue
    }
    
    
    /**
     * Returns the path that this `BlockPath` represents, in conformance with the
     * `CustomStringConvertible` protocol.
     */
    public var description: String {
        return self.hashPath()
    }
    
    
    /**
     * The individual parts of this path, stored in an array for easy processing. This
     * array typically contains a list of `BlockFace`s to which blocks are appended to
     * reach this particular block from the root. For example, for "up" -> "left" ->
     * "left", the block at this path is connected to the root block by a block on the
     * root block's top face, a block on *that* block's left face, and a block on **that**
     * block's left face.
     *
     * The root block will have an empty [String] for this value.
     */
    private var pathComponents: [String]

    
    /**
     * Initializes a `BlockPath` with the given string path. The input string will be
     * split by slashes to form the `pathComponents` array.
     *
     * - parameters:
     *     - path: `(String)` the path that this `BlockPath` should represent, with
     *             individual components delimited by slashes (`/`).
     */
    convenience init(_ path: String) {
        self.init(path.split(regex: "/")!)
    }
    
    
    /**
     * Initializes a `BlockPath` with the given path components.
     */
    init(_ path: [String]) {
        pathComponents = path.map({ $0.copy() }) as! [String]
    }
    
    
    /**
     * Returns how many levels away from the root block the block at this `BlockPath` is.
     * Typically, this is optimized by the level builder by checking all blocks to which
     * a block can be attached. So, for example, if we're using cubes exclusively, then
     * attempting to insert a cube at `up/left/down` optimizes to just `left`, because
     * that block could be placed either on the downwards face of `up/left` or on the
     * left face of the root block.
     *
     * - returns: `(Int)` the number of elements in `pathComponents`, which represents
     *            how far away the block at this `BlockPath` is from the root block.
     */
    public func distance() -> Int {
        return pathComponents.count
    }
    
    
    /**
     * Returns the `index`th component in the path, or `nil` if `index >= distance()`.
     *
     * - parameters:
     *     - index: `(Int)` the index of the element to retrieve.
     *
     * - returns: `(String?)` the element at `pathComponents[index]`, or `nil` if the
     *            `index` is out of bounds.
     */
    public func elemAt(_ index: Int) -> String? {
        return pathComponents[index]
    }
    
    
    /**
     * Creates a new `BlockPath` object with an additional element in the path. This is
     * useful when attaching a block; the next `Block`'s `path` is simply the result of
     * `self.path.append(nextComponent)`, where `nextComponent` is the name of some
     * `BlockFace`.
     *
     * - parameters:
     *     - nextComponent: `(String)` the element to add on to this `BlockPath`'s array
     *                      of components.
     *
     * - returns: `(BlockPath)` a new `BlockPath` whose `pathComponents` array is a deep
     *            copy of the current `BlockPath`'s `pathComponents` array, except with
     *            the element `nextComponent` tacked on to the end.
     */
    public func append(_ nextComponent: String) -> BlockPath {
        var updatedPath = pathComponents.map({ $0.copy() }) as! [String]
        updatedPath.append(nextComponent)
        
        return BlockPath(updatedPath)
    }
    
    public func simplify(rules: [String: String]) -> BlockPath {
        return BlockPath(simplifyRecursive(rules: rules, path: self.description))
    }

    private func simplifyRecursive(rules: [String: String], path: String) -> String {
        if !path.contains("/") {
            return path
        }

        let split = path.split(regex: "/")!

        var i = 0
        while i < split.count - 1 {
            let first = split[i], second = split[i + 1]
            guard let shortcut = rules[first] else {
                i += 1
                continue
            }

            if second == shortcut {
                var joined = split.joinedRange(separator: "/", min: 0, max: i)
                           + "/"
                           + split.joinedRange(separator: "/",
                                               leftTrim: i + 2,
                                               rightTrim: 0)

                joined = joined.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                return self.simplifyRecursive(rules: rules, path: joined)
            }

            i += 1
        }


        return path
    }
    
    
    /**
     * Gets the address of the block to which the block at this `BlockPath` is attached.
     */
    public func parentBlockAddress() -> BlockPath {
        if self.distance() == 0 {
            return BlockPath([])
        }
        
        var updatedPath = pathComponents.map({ $0.copy() }) as! [String]
        updatedPath.remove(at: updatedPath.count - 1)
        
        return BlockPath(updatedPath)
    }
    
    
    /**
     * Gets the final face described by this `BlockPath`.
     */
    public func latestElement() -> String {
        if self.distance() == 0 {
            return "root"
        }
        
        return pathComponents[pathComponents.count - 1]
    }
    
    
    /**
     * Returns a version of this `BlockPath`'s path with the components delimited by
     * periods (`.`). This was written in anticipation for the idea that individual
     * blocks in an `SCNScene` would have unique node names, but it is currently
     * uncertain whether that is even required since multiple nodes can have the same
     * name. It may just end up being necessary to manipulate unique blocks properly,
     * so we'll keep it around for now.
     *
     * - returns: `(String)` the path represented by this `BlockPath`, with individual
     *            components delimited by periods (`.`).
     *
     * - important: This function will **not** work with the constructor `init(String)`,
     *              as that initializer splits by slashes (`/`) and not periods. Use the
     *              `hashPath()` function instead.
     */
    public func nodalPath() -> String {
        return self.distance() == 0 ? "root" : pathComponents.joined(separator: ".")
    }
    
    
    /**
     * Returns a version of this `BlockPath`'s path with the components delimited by
     * slashes (`/`). The `hashValue` of each `BlockPath` is determined by the `hashValue`
     * of the `String` that this function returns.
     *
     * - returns: `(String)` the path represented by this `BlockPath`, with individual
     *            components delimited by slashes (`/`).
     */
    public func hashPath() -> String {
        return self.distance() == 0 ? "root" : pathComponents.joined(separator: "/")
    }
    
    
    /**
     * Generates the `hashValue` of this `BlockPath`, which is the result of
     * `self.hashPath().hashValue`.
     *
     * - returns: `(Int)` the hash value of this `BlockPath` as described above.
     */
    private func generateHash() -> Int {
        return self.hashPath().hashValue
    }
    
    
    /**
     * Compares two `BlockPath` objects, as required by the `Equatable` protocol.
     *
     * - parameters:
     *     - left:  `(BlockPath)` the left-hand `BlockPath` in the expression
     *              `left == right`.
     *     - right: `(BlockPath)` the right-hand `BlockPath` in the expression
     *              `left == right`.
     *
     * - returns: `(Bool)` `true` if `left` and `right` are equivalent;
     *            `false` otherwise.
     */
    public static func == (left: BlockPath, right: BlockPath) -> Bool {
        if left.distance() != right.distance() {
            return false
        }
        
        for i in 0 ..< left.distance() {
            if left.elemAt(i)! != right.elemAt(i)! {
                return false
            }
        }
        
        return true
    }
    
}
