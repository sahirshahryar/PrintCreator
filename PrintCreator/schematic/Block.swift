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
 * Represents a block within a model.
 *
 * - author:  Sahir Shahryar
 * - since:   Monday, June 4, 2018
 * - version: 1.0.0
 */
public class Block: CustomStringConvertible {

    /**
     * This string represents the type of block this `Block` is.
     */
    private var type: String
    
    /**
     * A collection of nodes that make up this block in the actual 3D rendering space.
     */
    private var model3d: [SCNNode]
    
    
    /**
     * The path to this block. This represents the location of this block relative to the
     * root block in the model.
     */
    public var path: BlockPath
    
    
    /**
     * The position of this block in a scene.
     */
    public var pos: Vector
    
    
    /**
     * The rotation of this block in a scene.
     */
    public var rot: Quaternion
    
    
    /**
     * The faces of this block. These are necessary to handle the geometry between
     * blocks correctly.
     */
    private var faces: [String: BlockFace]
    
    
    /**
     * These are the faces *that belong to the neighboring blocks* attached to this block.
     */
    private var neighborAttachedFaces: [String: BlockFace?]
    
    
    /**
     * This is a list of simplifications 
     */
    private var faceSimplifications: [String: String]
    
    
    /**
     *
     */
    public var isVisible: Bool
    
    
    /**
     *
     */
    private var color: Color
    
    
    /**
     *
     */
    public var description: String {
        return ((self.isVisible ? self.color.getName() : "invisible")
             + " \(self.type) at \(self.path)").trim()
    }

    
    /**
     *
     */
    public init(path: BlockPath, filename: String, type: String,
                faces: [String: BlockFace], simplifications: [String: String]) {
        self.path    = path
        self.type    = type
        self.model3d = Block.getNodesExcludingCamera(filename: filename)
        
        self.pos = Vector(0, 0, 0)
        self.rot = Quaternion(0, 0, 0, 0)
        
        self.faces               = faces
        self.faceSimplifications = simplifications
        
        self.isVisible = true
        self.color = Color.white
        
        self.neighborAttachedFaces = [String: BlockFace?]()
        self.establishAttachedNodesDictionary()
    }
    
    
    /**
     *
     */
    public convenience init(path: BlockPath, filename: String, type: String) {
        self.init(path: path,
                  filename: filename,
                  type: type,
                  faces: [String: BlockFace](),
                  simplifications: [String: String]())
    }

    /**
     *
     */
    public func getType() -> String {
        return self.type
    }
 
    /**
     *
     */
    public func getPath() -> BlockPath {
        return self.path
    }
    
    
    /**
     *
     */
    public func getFaces() -> [String: BlockFace] {
        return self.faces
    }
    
    
    /**
     * 
     */
    public func getRotatedFace(_ name: String) -> BlockFace? {
        guard let face = self.faces[name] else {
            return nil
        }
        
        return BlockFace(name: face.name,
                         pegs: face.pegs,
                         dir: face.dir.rotate(by: self.rot),
                         rot: face.rotation)
    }
    
    
    /**
     *
     */
    public func attachBlock(toFace: String, newBlock: Block,
                            faceOnNewBlock: String) -> Bool {
        if faces[toFace] != nil {
            guard let newFace = newBlock.faces[faceOnNewBlock] else {
                return false
            }
            
            neighborAttachedFaces[toFace] = newFace
        }
        
        return false
    }
    
    
    /**
     *
     */
    public func setVisible(_ visible: Bool = true) {
        self.isVisible = visible
    }
    
    
    /**
     *
     */
    public func setColor(_ color: Color) {
        self.color = color
    }
    
    
    /**
     *
     */
    public func render(scene: SCNScene) {
        if !self.isVisible {
            return
        }
        
        self.color.interpret(nodes: model3d)
        var first = false
        for node in model3d {
            node.localTranslate(by: pos)
            node.rotate(by: rot, aroundTarget: pos)
            
            if first {
                node.name = "block" + self.path.description
                first = false
            }
            
            scene.rootNode.addChildNode(node)
        }
    }

    public func getBounds() -> Cuboid {
        var min = self.pos, max = self.pos

        for (_, face) in self.faces {
            min = Vector.min(min, self.pos + face.dir)
            max = Vector.max(max, self.pos + face.dir)
        }

        return Cuboid(min: min, max: max)
    }

    public func hypotheticalBounds(attachedTo: Block,
                                   on: BlockFace, by: BlockFace) -> Cuboid {
        let pos = attachedTo.pos + on.dir + (-by.dir)

        var min = pos, max = pos

        for (_, face) in self.faces {
            min = Vector.min(min, pos + face.dir)
            max = Vector.max(max, pos + face.dir)
        }

        return Cuboid(min: min, max: max)
    }

    public func getNewBlockFace(camera: Vector, tap: Vector,
                    newBlock: Block) -> (original: BlockFace, new: BlockFace)? {
        /* let RAD_TO_DEG = 180 / Float.pi
        let yaw = camera.yaw(relativeTo: tap) * RAD_TO_DEG,
          pitch = camera.pitch(relativeTo: tap) * RAD_TO_DEG

        if pitch > 45 {

        } */

        let testLocation = tap.rewind(origin: camera, distance: 0.1)
        print("rewind = \(testLocation)")




        for (name, face) in faces {
            guard let oppositeFaceName = self.faceSimplifications[name] else {
                return nil
            }

            guard let oppositeFace = self.faces[oppositeFaceName] else {
                return nil
            }

            let bounds = newBlock.hypotheticalBounds(attachedTo: self,
                                                     on: face, by: oppositeFace)

            if bounds.contains(testLocation) {
                return (face, oppositeFace)
            }
        }

        return nil
    }

    
    /**
     *
     */
    private func establishAttachedNodesDictionary() {
        for (dir, _) in self.faces {
            self.neighborAttachedFaces[dir] = nil
        }
    }
    
    
    /**
     *
     */
    private static func getNodesExcludingCamera(filename: String) -> [SCNNode] {
        let scene = SCNScene(named: filename)!
        
        var result = [SCNNode]()
        scene.rootNode.childNodes.filter({ $0.name != "camera" })
                                 .forEach({ result.append($0) })
        
        return result
    }
    
}
