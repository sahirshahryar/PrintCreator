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
 *
 * - author:  Sahir Shahryar
 * - since:   Monday, June 18, 2018
 * - version: 1.0.0
 */
public class StartScreen: UIViewController {

    /**
     *
     */
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }


    /**
     *
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }


    /**
     *
     */
    @IBAction func unwindHere(segue: UIStoryboardSegue) {
        // Dummy method
    }


    /**
     *
     */
    @IBAction public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let buttonType = segue.identifier else {
            return
        }
        
        if sender == nil || !(sender! is UIButton) {
            return
        }
        
        let button = sender! as! UIButton
        
        if button is FileChooserOpeningButton {
            if !(segue.destination is FileChooserNavigationController) {
                return
            }
            
            let chooser = segue.destination as! FileChooserNavigationController
            
            if buttonType == "PresetSegue" {
                chooser.choosableFiles = [ "basic.mdl", "stickfigure.mdl", "cube.mdl",
                                           "footballer.mdl"]
                chooser.directory = ""
            } else if buttonType == "OpenSegue" {
                chooser.choosableFiles = FileInterface.listFiles()
                chooser.directory = "userfiles"
            }
        }
        
        
        /* print("segue called")
        if !(segue.source is StartScreen) {
            print("not from start screen")
            return
        }
        
        if sender == nil || !(sender! is UIButton) {
            return
        }
        
        let button = sender! as! UIButton
        
        
        if button is OpenExistingModelButton {
            FileChooser.choosableFiles = FileInterface.listFiles()
        } else if button is OpenPresetButton {
            FileChooser.choosableFiles = [ "basic.mdl", "stickfigure.mdl", "footballer.mdl",
                                           "cube.mdl" ]
            // choosableFiles = FileInterface.listFiles(folder: FileInterface.PRESET_STORAGE)
        } */
        
    }
    
}


/**
 *
 */
public class FileChooserOpeningButton: UIButton {
    
}
