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
import SceneKit
import QuartzCore

/**
 * This class represents the view that is actually used to preview and render models.
 *
 * - author:  Sahir Shahryar
 * - since:   Thursday, June 14, 2018
 * - version: 1.0.0
 */
public class Viewport: UIViewController {

    /**
     *
     */
    private static let EMPTY_SCENE = "art.scnassets/blank.scn"


    /**
     *
     */
    private var editHistory = EditHistory()


    /**
     *
     */
    public var filename: String?


    /**
     *
     */
    public var modelView: ModelView?


    /**
     *
     */
    public var editorPane: EditorPane?


    /**
     *
     */
    private var elements = [String: UIView]()
    

    /**
     *
     */
    public init(file: String) {
        super.init(nibName: nil, bundle: nil)
        self.filename = file
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
    public func prepare() {
        self.modelView = ModelView(frame: UIScreen.main.bounds,
                                   parent: self,
                                   model: nil,
                                   scene: SCNScene(named: ModelView.EMPTY_SCENE))
    }


    /**
     *
     */
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if !self.loadModelView() {
            PrintCreatorMain.loadedModelView = nil
        }

        self.loadNavBarItems()
        if self.modelView != nil {
            self.loadEditorPane()
            PrintCreatorMain.loadedModelView = (file: filename!,
                                                model: self.modelView!,
                                                editor: self.editorPane!)
        }
    }

    /**
     *
     */
    public override func viewDidLoad() {
        super.viewDidLoad()
    }


    /**
     * 
     */
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.editorPane?.flickDown(intensity: 0.5)
    }


    /**
     *
     */
    private func loadNavBarItems() {
        guard let model = self.modelView else {
            return
        }

        if self.navigationController == nil {
            return
        }

        let title: String
        if let name = self.filename {
            title = name.trim("/") + ".mdl"
        } else {
            title = "viewer.generic-model-name".localize()
        }

        let count = model.model?.visibleCount() ?? 0
        let subtitle = count.pluralize(zero: "viewer.block-count-zero",
                                       one: "viewer.block-count-singular",
                                       plural: "viewer.block-count-plural",
                                       blanks: count.getNiceNumber())

        let titleBar = SubtitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titleBar.title = title
        titleBar.subtitle = subtitle

        titleBar.sizeToFit()
        self.navigationItem.titleView = titleBar

        self.elements["title"] = titleBar
    }


    /**
     *
     */
    private func loadEditorPane() {
        func build() {
            editorPane = EditorPane(nibName: "EditorPaneView", bundle: nil)
            editorPane!.parentView = self

            editorPane!.view.frame = CGRect(x: 0,
                                            y: self.view.frame.maxY,
                                            width: self.view.frame.width,
                                            height: 300)
        }

        if let (file, _, editor) = PrintCreatorMain.loadedModelView {
            if file == filename! {
                editorPane = editor
            } else {
                build()
            }
        } else {
            build()
        }

        self.addChildViewController(editorPane!)
        self.view.addSubview(editorPane!.view)
        editorPane!.didMove(toParentViewController: self)
    }


    /**
     *
     */
    private func loadModelView() -> Bool {
        if let (file, view, _) = PrintCreatorMain.loadedModelView {
            if file == filename! {
                self.modelView = view
                self.view = view
                return true
            }
        }

        /**
         * This function will be used to go back to the previous view if there's an error.
         */
        func goBack() {
            let _ = navigationController?.popViewController(animated: true)
        }

        guard let file = self.filename else {
            self.showErrorMessage(title: "model-view-error.title".localize(),
                                  subtitle: "model-view-error.no-file-passed".localize(),
                                  okButton: "gui-basics.ok".localize(),
                                  okAction: goBack)

            return false
        }


        /**
         * Try to find the file being loaded.
         */
        let bundle = Bundle.init(for: type(of: self))
        guard let path = bundle.path(forResource: file, ofType: "mdl") else {
            self.showErrorMessage(title: "model-view-error.title".localize(),
                                  subtitle: "model-view-error.file-not-located"
                                            .localize(file),
                                  okButton: "gui-basics.ok".localize(),
                                  okAction: goBack)

            return false
        }


        /**
         * Next, try to parse the model file.
         */
        do {
            if self.modelView == nil {
                self.modelView = ModelView(frame: UIScreen.main.bounds,
                                           parent: self, model: nil)
            }

            if self.modelView!.model == nil {
                self.modelView!.model
                    = try createComponent(path,
                                          knownBlockTypes: BlockTypes.ALL_BLOCK_TYPES)
            }

            try self.modelView!.render()

            self.view = self.modelView

            return true
        } catch let error as MDLParseError {
            self.showErrorMessage(title: "mdl-parse-error.dialog-title".localize(),
                                  subtitle: error.getMessage(),
                                  okButton: "gui-basics.ok".localize(),
                                  okAction: goBack)
        } catch let error as ModelRenderingError {
            self.showErrorMessage(title: "rendering-error.title".localize(),
                                  subtitle: error.getMessage(),
                                  okButton: "gui-basics.ok".localize(),
                                  okAction: goBack)

        } catch {
            /**
             * For some reason, `catch let error as MDLParseError` is not considered
             * exhaustive for the `createComponent` method, so this empty `catch` block
             * is required.
             */
        }

        return false
    }


    public func blockCountChanged(newCount: Int) {
        guard let title = self.elements["title"] as? SubtitleView else {
            return
        }

        let subtitle = newCount.pluralize(zero: "viewer.block-count-zero",
                                          one: "viewer.block-count-singular",
                                          plural: "viewer.block-count-plural",
                                          blanks: newCount.getNiceNumber())
        title.subtitle = subtitle
    }

}
