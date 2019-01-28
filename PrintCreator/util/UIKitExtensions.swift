//
//  UIKitExtensions.swift
//  PrintCreator
//
//  Created by Sahir Shahryar on 7/8/18.
//  Copyright © 2018 Sahir Shahryar. All rights reserved.
//

import Foundation
import UIKit

public extension UIFont {

    public func withWeight(_ weight: UIFont.Weight) -> UIFont {
        return UIFont.systemFont(ofSize: self.pointSize, weight: weight)
    }

    public func boldfaced() -> UIFont {
        return self.withWeight(.bold)
    }

}

public extension UIView {

    public func findChild<T: UIView>(type clazz: T.Type) -> T? {
        for child in self.subviews {
            if type(of: child) == clazz {
                return (child as! T)
            }

            if let answer = child.findChild(type: clazz) {
                return answer as T
            }
        }

        return nil
    }


}
