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
 * This class represents a series of blocks that are attached together.
 *
 * @author  Sahir Shahryar
 * @since   Sunday, May 27, 2018
 * @version 1.0.0
 */
public class Component {
    
    /**
     * Represents the root block of the model. All blocks in this `Component` are located
     * relative to this block. If this block is `nil`, then it is not possible to add any
     * other blocks to the model — the root block *must* be the first block added to the
     * model.
     */
    private var root: Block?
    
    
    /**
     * A dictionary containing all of the blocks in this `Component`. They are addressable
     * by their `BlockPath`s; thus, knowing the location of a block allows one to access
     * that block specifically. Pegs are **not** considered blocks.
     */
    private var blocks: [BlockPath: Block]

    
    /**
     * Initializes an empty `Component`.
     */
    init() {
        root   = nil
        blocks = [BlockPath: Block]()
    }
    
    
    /**
     * Tries to load a `Component` from the given file.
     *
     * - parameter file: `(String)` the name of the file to load.
     *
     * - throws: `(MDLParseError et al.)` thrown if the creation of the `Component` failed
     *           for some reason, typically due to a syntax error in the supplied `.mdl`
     *           file.
     */
    convenience init?(file: String) throws {
        self.init()
        
        let obj     = try createComponent(file,
                                          knownBlockTypes: BlockTypes.ALL_BLOCK_TYPES)
        self.root   = obj.root
        self.blocks = obj.blocks
    }

    
    /**
     * Establishes the root block of this component, allowing other blocks to be added
     * relative to it.
     *
     * - parameters:
     *     - block: `(Block)` The `Block` that should be the root of this `Component`.
     *     - force: `(Bool)` whether the setting of the root block should be forced.
     *              This value defaults to `false` and should not be overridden unless
     *              absolutely necessary. Setting `force = true` and performing operations
     *              that would otherwise be deemed illegal voids any guarantees about
     *              the correct functioning of related properties of `Component`, such as
     *              rendering or slot vacancy checking.
     */
    public func establishRoot(_ block: Block?, force: Bool = false) {
        if force || root == nil {
            root = block
        }
    }
    
    
    /**
     * Returns the root block of this `Component`, if it exists.
     *
     * - returns: `(Block?)` the root of this `Component`, or `nil` if the root block
     *            doesn't exist.
     */
    public func getRoot() -> Block? {
        return root
    }

    
    /**
     * Gets the block at the given path, if it exists. This method is preferred to simply
     * using `blocks[path]`, because it allows access to the root block without requiring
     * a special case for when `path.distance() == 0`.
     *
     * - parameter path: `(BlockPath)` the path of the block to fetch.
     *
     * - returns: `(Block?)` the block at the given `BlockPath`, or `nil` if there is no
     *            block at the given path.
     */
    public func getBlock(_ path: BlockPath) -> Block? {
        if root == nil {
            return nil
        }
        
        if path.distance() == 0 {
            return root
        }
        
        return blocks[path]
    }
    
    
    /**
     *
     */
    public func getBlocks() -> [Block] {
        var result = [Block]()
        
        for (_, block) in blocks {
            result.append(block)
        }
        
        return result
    }
    
    
    /**
     * Returns the number of blocks in this `Component`. This is preferred to simply using
     * `blocks.count` because it counts the root block as well.
     *
     * - returns: `(Int)` the number of blocks in this `Component`.
     */
    public func getBlockCount() -> Int {
        return hasRoot() ? 1 + blocks.count
                         : 0
    }
    
    
    /**
     * Prints out a list of blocks in this `Component` to the debugger console, or the
     * string `"Component is empty"` if there aren't any blocks in this `Component`.
     */
    public func printBlockPositions() {
        if root == nil {
            print("Component is empty")
            return
        }
        
        print(root!)
        for (_, block) in blocks {
            print(block)
        }
    }

    /**
     *
     */
    public func getDimensions() -> Vector {
        var minX = 0.5, minY = 0.5, minZ = 0.5
        var maxX = 0.5, maxY = 0.5, maxZ = 0.5

        for (_, block) in self.blocks {
            let x = Double(block.pos.x),
                y = Double(block.pos.y),
                z = Double(block.pos.z)

            if x > 0.0 && x > maxX { maxX = x }
            if x < 0.0 && x < minX { minX = x }

            if y > 0.0 && y > maxY { maxY = y }
            if y < 0.0 && y < minY { minY = y }

            if z > 0.0 && z > maxZ { maxZ = z }
            if z < 0.0 && z < minZ { minZ = z }
        }



        /**
         * A more elegant way to write "-minX + maxX" is to write "maxX - minX".
         */
        return Vector(maxX - minX, maxY - minY, maxZ - minZ)
    }

    public func getBlockAt(_ pos: Vector) -> Block? {
        guard let rootBlock = self.root else {
            return nil
        }

        print(pos)

        if rootBlock.getBounds().min == pos {
            return rootBlock
        }

        for (_, block) in self.blocks {
            if block.getBounds().min == pos {
                return block
            }
        }

        return nil
    }
    
    
    /**
     * Determines if this `Component` has a root already.
     *
     * - returns: `(Bool)` `true` if `root != nil`; `false` otherwise.
     */
    public func hasRoot() -> Bool {
        return root != nil
    }
    
    
    /**
     * Adds a new `Block` to this `Component`.
     *
     * - parameters:
     *     - newBlock: `(Block)` the new block to be added to this `Component`. The path
     *                 of the new block is determined automatically from the path
     *                 specified in the `path` instance variable of `newBlock`.
     *     - newBlockFace: `(String)` the name of the `BlockFace` **on** `newBlock`
     *                     (**read that carefully**) that will be attached to the parent
     *                     block. This is necessary in order to correctly determine the
     *                     position of `newBlock` in 3D space.
     *     - force: `(Bool)` whether or not safety checks should by bypassed in favor of
     *              forcing `newBlock` into the given position. This is set to `false` by
     *              default and should not be set to `true` unless *absolutely* necessary.
     *              Setting `force = true`, then subsequently performing operations that
     *              would otherwise be rejected as illegal, voids all guarantees about
     *              the correct functioning of `Component`, such as rendering or slot
     *              vacancy checking.
     */
    public func addBlock(_ newBlock: Block,
                         newBlockFace newBlockFaceName: String,
                         force: Bool = false,
                         scene: SCNScene? = nil) throws {
        /**
         * If the `force` option was used, just force the block addition.
         */
        if force {
            if newBlock.getPath().distance() == 0 {
                self.root = newBlock
            } else {
                blocks[newBlock.getPath()] = newBlock
            }

            if scene != nil {
                newBlock.render(scene: scene!)
            }
            
            return
        }
        
        let parent: Block
        
        /**
         * First, check if this block is adjacent to the root block.
         */
        if newBlock.getPath().distance() < 2 {
            if self.root == nil {
                throw BlockAdditionError.noRootBlock(block: newBlock)
            }
            
            parent = self.root!
        }
        
        /**
         * If it's not adjacent, then check if the parent block exists already.
         */
        else {
            let parentAddress = newBlock.getPath().parentBlockAddress()
            guard let candidate = self.getBlock(parentAddress) else {
                throw BlockAdditionError
                      .parentBlockNonexistent(block: newBlock)
            }
            
            parent = candidate
        }
        
        /**
         * Ensure that the parent actually has the face specified in `newBlock`' path, and
         * make sure that `newBlock` actually has the face specified in
         * `newBlockFaceName`.
         */
        let parentFaceName = newBlock.getPath().latestElement()
        guard let parentFace = parent.getFaces()[parentFaceName] else {
            throw BlockAdditionError.invalidParentFace(block: newBlock,
                                                       name: parentFaceName)
        }
        
        guard let newBlockFace = newBlock.getRotatedFace(newBlockFaceName) else {
            throw BlockAdditionError.invalidNewBlockFace(block: newBlock,
                                                         name: newBlockFaceName)
        }
        
        /**
         * If the given position is actually vacant,
         */
        if self.isVacant(newBlock.getPath()) {
            let newPos = parent.pos + parentFace.dir + (-newBlockFace.dir)
            let newRot = parent.rot + parentFace.rotation + newBlockFace.rotation
            
            newBlock.pos = newPos
            newBlock.rot = newRot
            
            blocks[newBlock.getPath()] = newBlock

            if scene != nil {
                newBlock.render(scene: scene!)
            }

            return
        }
        
        throw BlockAdditionError
              .slotOccupied(block: newBlock,
                            preexisting: self.getBlock(newBlock.getPath())!)
    }
    
    
    /**
     *
     */
    public func isVacant(_ path: BlockPath) -> Bool {
        return !blocks.keys.contains(path)
    }
    
    
    /**
     *
     */
    public func simplifyPath(_ path: BlockPath) -> BlockPath {
        return path
        // TODO
    }
    
    
    /**
     *
     */
    public func count() -> Int {
        if root != nil {
            return blocks.count + 1
        }
        
        return 0
    }
    

    /**
     *
     */
    public func visibleCount() -> Int {
        if let start = self.root {
            var count = 0

            if start.isVisible {
                count += 1
            }

            for (_, block) in blocks {
                if block.isVisible {
                    count += 1
                }
            }

            return count
        }

        return 0
    }
    
    
    /**
     *
     */
    public func render(scene: SCNScene,
                       pos: Vector = Vector(0, 0, 0),
                       rot: Quaternion = Quaternion(0, 0, 0, 0)) {
        guard let root = self.getRoot() else {
            return
        }
        
        // 1. Render the root block.
        root.render(scene: scene)
        
        // 2. Render all other blocks.
        for (_, block) in blocks {
            block.render(scene: scene)
        }
    }
    
    
    /**
     * Converts the given `BlockAdditionError` message into a user-readable string.
     *
     * - parameter error: `(BlockAdditionError)` the error that occurred.
     *
     * - returns: `(String)` a string describing that error.
     */
    public static func getErrorMessage(_ error: BlockAdditionError) -> String {
        switch error {
        case .noRootBlock(let block):
            return "no root block was defined prior to addition of \(block)"
            
        case .parentBlockNonexistent(let block):
            return "unable to add \(block) because no block exists at the parent " +
                   "path \(block.getPath().parentBlockAddress())"
            
        case .invalidParentFace(let block, let face):
            return "unable to attach \(block) because the parent block at " +
                   "\(block.getPath().parentBlockAddress()) has no face known as \(face)"
            
        case .invalidNewBlockFace(let block, let face):
            return "unable to attach \(block) because it does not have a block face " +
                   "known as \(face)"
            
        case .slotOccupied(let block, let preexistingBlock):
            return "unable to attach \(block) because that slot is already occupied by " +
                   "\(preexistingBlock)"
        }
    }
    
}


/**
 *
 */
public enum BlockAdditionError: Error {
    /**
     *
     */
    case noRootBlock            (block: Block)
    
    /**
     *
     */
    case parentBlockNonexistent (block: Block)
    
    /**
     *
     */
    case invalidParentFace      (block: Block, name: String)
    
    /**
     *
     */
    case invalidNewBlockFace    (block: Block, name: String)
    
    /**
     *
     */
    case slotOccupied           (block: Block, preexisting: Block)
}
