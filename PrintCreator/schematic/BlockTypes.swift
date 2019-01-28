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
 * - author:  Sahir Shahryar
 * - since:   Tuesday, June 5, 2018
 * - version: 1.0.0
 */
public class BlockTypes {
    
    /**
     *
     */
    public static let ALL_BLOCK_TYPES: [String] = [
        "cube"
    ]
    
    
    /**
     *
     */
    public static let RESOURCE_LOCATIONS: [String: String] = [
        "cube": "art.scnassets/cube.scn",
        "peg": "art.scnassets/peg3d.scn"
    ]
    
    
    /**
     *
     */
    public static func makeBlock(type: String,
                                 path: BlockPath = BlockPath.ROOT_PATH) -> Block? {
        switch type {
        case "cube":
            return makeCube(path: path)
            
        default:
            return nil
        }
    }
    
    
    /**
     *
     */
    public static func makeCube(path: BlockPath = BlockPath.ROOT_PATH) -> Block {
        return Block(           path: path,
                            filename: RESOURCE_LOCATIONS["cube"]!,
                                type: "cube",
                               faces: CUBE_FACES,
                     simplifications: CUBE_SIMPLIFICATIONS)
    }
    
    
    /**
     *
     */
    private static let CUBE_SIMPLIFICATIONS: [String: String] = [
        "U": "D", "D": "U",
        "N": "S", "S": "N",
        "E": "W", "W": "E"
    ]
    
    
    /**
     *
     */
    private static let CUBE_PEG_OFFSET = 20 - 2.5
    
    
    /**
     *
     */
    private static let CUBE_PEGS = [
            Peg(x:  CUBE_PEG_OFFSET, y:  CUBE_PEG_OFFSET, scaleTo: 20 * 0.5),
            Peg(x: -CUBE_PEG_OFFSET, y: -CUBE_PEG_OFFSET, scaleTo: 20 * 0.5),
            Peg(x:  CUBE_PEG_OFFSET, y: -CUBE_PEG_OFFSET, scaleTo: 20 * 0.5),
            Peg(x: -CUBE_PEG_OFFSET, y:  CUBE_PEG_OFFSET, scaleTo: 20 * 0.5)
    ]
    
    /**
     *
     */
    private static let CUBE_FACES: [String: BlockFace] = [
        /**
         * This represents the north `BlockFace`.
         *
         *         U  N
         *         ^ ^
         *         |/
         *    W <--+--> E
         *        /|
         *       v v
         *       S D
         *
         * U: +y, D: -y
         * N: +x, S: -x
         * E: +z, W: -z
         */
        "N": BlockFace(
            name: "N",
            pegs: CUBE_PEGS,
            dir: Vector(0.5, 0, 0),
            rot: Quaternion(0, 0, 0, 0)
        ),
        
        "S": BlockFace (
            name: "S",
            pegs: CUBE_PEGS,
            dir: Vector(-0.5, 0, 0),
            rot: Quaternion(0, 0, 0, 0)
        ),

        "E": BlockFace (
            name: "E",
            pegs: CUBE_PEGS,
            dir: Vector(0, 0, 0.5),
            rot: Quaternion(0, 0, 0, 0)
        ),
        
        "W": BlockFace (
            name: "W",
            pegs: CUBE_PEGS,
            dir: Vector(0, 0, -0.5),
            rot: Quaternion(0, 0, 0, 0)
        ),
        
        
        "U": BlockFace (
            name: "U",
            pegs: CUBE_PEGS,
            dir: Vector(0, 0.5, 0),
            rot: Quaternion(0, 0, 0, 0)
        ),
        
        "D": BlockFace (
            name: "D",
            pegs: CUBE_PEGS,
            dir: Vector(0, -0.5, 0),
            rot: Quaternion(0, 0, 0, 0)
        )
    
    ]
    
    
    
}
