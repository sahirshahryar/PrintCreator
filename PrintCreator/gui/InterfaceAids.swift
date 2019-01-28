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

/**
 *
 * - author:  Sahir Shahryar
 * - since:   Thursday, June 14, 2018
 * - version: 1.0.0
 */
public extension UIViewController {

    /**
     *
     */
    public func showErrorMessage(title: String, subtitle: String,
                                 okButton: String = "OK",
                                 okAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: subtitle,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default,
                                      handler: okAction == nil ? nil
                                                               : { _ in okAction!() }))
        
        self.present(alert, animated: true, completion: nil)
    }


    /**
     *
     */
    public func showSelector<T>(style: UIAlertController.Style,
                                title: String, subtitle: String?,
                                options: [T: (label: String, type: UIAlertAction.Style?)],
                                order: [T]? = nil,
                                action: @escaping (T) -> Void) throws {
        
        let alert = UIAlertController(title: title,
                                      message: subtitle,
                                      preferredStyle: style)
        
        /**
         * Can you do THAT in Java?
         */
        func add(_ key: T, _ value: (label: String, type: UIAlertAction.Style?)) {
            alert.addAction(UIAlertAction(title: value.label,
                                          style: value.type ?? .default,
                                          handler: { _ in action(key) } ))
        }
        
        if order != nil {
            for key in order! {
                guard let value = options[key] else {
                    throw InterfaceAidError.nonmatchingOrderArray
                }
                
                add(key, value)
            }
        } else {
            for (key, value) in options {
                add(key, value)
            }
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
}


/**
 *
 */
public enum InterfaceAidError: Error {
    case nonmatchingOrderArray
}
