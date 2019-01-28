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
import UIKit
import QuartzCore
import SceneKit


/**
 * - author:  Sahir Shahryar
 * - since:   Sunday, June 3, 2018
 * - version: 1.0.0
 */
class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // create a new scene
        guard var scene = SCNScene(named: "art.scnassets/blank.scn") else {
            print("Unable to find cube.scn")
            return
        }
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let models: [String: (String, UIAlertAction.Style?)] =
            [ "cube": ("Cube", nil),
              "stickfigure": ("Stick figure", nil),
              "footballer": ("Footballer", nil),
              "basic": ("Basic", nil) ]
        
        do {
            try self.showSelector(style: .actionSheet,
                          title: "Select file",
                          subtitle: "Choose which file to render.",
                          options: models,
                          order: [ "cube", "stickfigure", "footballer", "basic" ],
                          action: { self.load(&scene, $0) })
        } catch {
            self.showErrorMessage(title: "Loading Failed",
                                  subtitle: "An error occurred while showing the file " +
                                            "chooser.")
        }
    }
    
    private func load(_ scene: inout SCNScene, _ model: String) {
        scene = self.loadModel(scene: scene, model: model)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    private func loadModel(scene: SCNScene, model: String) -> SCNScene {
        do {
            let bundle = Bundle.init(for: type(of: self))
            guard let path = bundle.path(forResource: model, ofType: "mdl") else {
                print("Unable to access resource")
                return scene
            }
            
            let model = try createComponent(path, knownBlockTypes: [ "cube" ])
            model.render(scene: scene)
            
            print("\(model.getBlockCount()) blocks")
            model.printBlockPositions()
        } catch let error as MDLParseError {
            self.showErrorMessage(title: "Parsing Failed",
                                  subtitle: error.getMessage())
        } catch {
            print("Unknown error")
        }
        
        return scene
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
