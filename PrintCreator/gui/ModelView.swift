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
 * This class represents the actual 3D scene being shown to edit a model.
 *
 * - author:  Sahir Shahryar
 * - since:   Monday, June 25, 2018
 * - version: 1.0.0
 */
public class ModelView: SCNView {

    /**
     *
     */
    public static let EMPTY_SCENE: String = "art.scnassets/blank.scn"


    /**
     *
     */
    public var model: Component? = nil


    /**
     *
     */
    private var blankScene: SCNScene? = nil


    private weak var parent: Viewport? = nil


    private var camera: SCNNode? = nil


    /**
     *
     */
    public init(frame: CGRect, file: String) throws {
        super.init(frame: frame)
    }


    /**
     *
     */
    public init(frame: CGRect, parent: Viewport, model: Component?, scene: SCNScene? = nil) {
        super.init(frame: frame)
        self.model = model
        self.blankScene = scene
        self.parent = parent
    }


    /**
     *
     */
    public override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
    }


    /**
     *
     */
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


    /**
     *
     */
    public func render() throws {
        /**
         * First, let's make sure the required objects (model and scene) actually exist.
         */
        if model == nil {
            throw ModelRenderingError.componentNil
        }

        let scene: SCNScene
        if self.blankScene == nil {
            if let newScene = SCNScene(named: ModelView.EMPTY_SCENE) {
                scene = newScene
            } else {
                throw ModelRenderingError.sceneNil
            }
        } else {
            scene = self.blankScene!
        }

        /**
         * Next, put in a camera.
         */
        camera = scene.rootNode.childNode(withName: "camera", recursively: true)!

        let dimensions = model!.getDimensions()

        let cameraPos = Vector(8, 4, 8) * max(dimensions.magnitude() / 4.0, 0.5)

        camera!.position = cameraPos
        scene.rootNode.addChildNode(camera!)

        self.allowsCameraControl = true

        scene.fogStartDistance = 100
        scene.fogEndDistance = 150

        let lightPos = dimensions.magnitude()


        /**
         * Finally, add some lighting.
         */
        for permutation in BinaryPermutation(bits: 2) {
            let light = SCNNode()
            light.light = SCNLight()
            light.light!.type = .omni
            light.light!.color = UIColor.lightGray

            let x = permutation[0] ? Int(lightPos) : 0
            let z = permutation[1] ? Int(lightPos) : 0

            light.position = Vector(x, 10, z)
            

            scene.rootNode.addChildNode(light)
        }

        model!.render(scene: scene)
        self.scene = scene

        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTap(gesture:)))

        self.addGestureRecognizer(tapGesture)
    }


    @objc func handleTap(gesture: UITapGestureRecognizer) {
        if gesture.numberOfTouches != 1 {
            return
        }

        let tappedLocation = gesture.location(in: self)
        let rayTrace = self.hitTest(tappedLocation, options: [:])

        if rayTrace.count == 0 {
            return
        }

        let targetPos = rayTrace[0].node.worldPosition

        guard let tappedBlock = self.model?.getBlockAt(targetPos) else {
            return
        }

        print(tappedBlock.path.description)

        let camera = self.pointOfView!.position

        let newBlock = BlockTypes.makeCube()

        guard let data = tappedBlock.getNewBlockFace(camera: camera,
                                                     tap: tappedBlock.pos,
                                                     newBlock: newBlock) else {
            return
        }

        // HUUUUUGE OPTIONAL CHAIN
        let color: Color = (parent?.editorPane?.uiElements[.colorPicker] as! ColorChooser).selection ?? .white

        newBlock.setColor(color)

        newBlock.path = tappedBlock.path.append(data.original.name)

        newBlock.pos = tappedBlock.pos + (-data.new.dir) + data.original.dir

        do {
            let _ = try self.model!.addBlock(newBlock,
                                             newBlockFace: data.new.name,
                                             force: false,
                                             scene: self.scene)

            parent?.blockCountChanged(newCount: self.model!.visibleCount())
        }

        catch {
            return
        }
    }

    
}


/**
 *
 */
public enum ModelRenderingError: Error {
    /**
     *
     */
    case componentNil

    /**
     *
     */
    case sceneNil


    /**
     *
     */
    func getMessage() -> String {
        switch self {
        case .componentNil:
            return "rendering-error.componentNil".localize()

        case .sceneNil:
            return "rendering-error.sceneNil".localize()
        }
    }
}
