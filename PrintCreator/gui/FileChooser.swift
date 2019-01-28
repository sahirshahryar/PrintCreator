//
//  FileChooser.swift
//  PrintCreator
//
//  Created by Sahir Shahryar on 6/25/18.
//  Copyright © 2018 Sahir Shahryar. All rights reserved.
//

import Foundation
import UIKit


/**
 *
 * - author:  Sahir Shahryar
 * - since:   Monday, June 25, 2018
 * - version: 1.0.0
 */
public class FileChooser: UITableViewController {

    /**
     *
     */
    fileprivate var choosableFiles: [String]? = nil


    /**
     *
     */
    fileprivate var directory: String? = nil

    /**
     *
     */
    public convenience init(files: [String]?) {
        self.init(nibName: nil, bundle: nil)
        self.choosableFiles = files
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
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    /**
     *
     */
    public override func tableView(_ tableView: UITableView,
                                   numberOfRowsInSection: Int) -> Int {
        return choosableFiles?.count ?? 0
    }


    /**
     *
     */
    public override func tableView(_ tableView: UITableView,
                                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filename",
                                                 for: indexPath)
        
        
        let filename = choosableFiles![indexPath.last!].split(regex: "\\.")!
                       .joinedRange(separator: ".", rightTrim: 1)
        
        cell.textLabel?.text = filename
        return cell
    }


    /**
     *
     */
    public override func tableView(_ tableView: UITableView,
                                   titleForHeaderInSection section: Int) -> String? {
        return nil
    }


    /**
     *
     */
    public override func tableView(_ tableView: UITableView,
                                   didSelectRowAt indexPath: IndexPath) {
        
    }


    /**
     *
     */
    @IBAction public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender == nil || !(sender is UITableViewCell) {
            return
        }

        let cell = sender as! UITableViewCell

        if segue.destination is Viewport {
            let dest = segue.destination as! Viewport
            let filename = (self.directory != nil ? self.directory! + "/" : "")
                         + cell.textLabel!.text!

            dest.filename = filename

            let backButton = UIBarButtonItem(title: "gui-basics.back".localize(),
                                             style: .plain,
                                             target: nil,
                                             action: nil)

            self.navigationItem.backBarButtonItem = backButton

            let activityIndicator
                = cell.findChild(type: FileChooserActivityIndicator.self)

            activityIndicator?.startAnimating()
            // UIApplication.shared.beginIgnoringInteractionEvents()

            dest.prepare()

            // UIApplication.shared.endIgnoringInteractionEvents()
            activityIndicator?.stopAnimating()
        }
    }
    
}


/**
 *
 */
public class FileChooserNavigationController: UINavigationController {

    /**
     *
     */
    public var directory: String? = nil


    /**
     *
     */
    public var choosableFiles: [String]? = nil


    /**
     *
     */
    private var chooserController: FileChooser? = nil


    /**
     *
     */
    public override func loadView() {
        super.loadView()
        
        for controller in self.viewControllers {
            if controller is FileChooser {
                let chooser = controller as! FileChooser
                chooser.choosableFiles = choosableFiles
                chooser.directory = directory
            }
        }
    }


    /**
     *
     */
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}


public class FileChooserActivityIndicator: UIActivityIndicatorView {

}
