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
 * Represents a list of standardized colors for use in blocks.
 *
 * - author:  Sahir Shahryar
 * - since:   Monday, June 11, 2018
 * - version: 1.0.0
 */
public enum Color: Hashable {
    case white
    case black
    case red
    case green
    case blue
    case lightBlue
    case purple
    case turquoise
    case peach

    case uiBlue
    
    case random
    case custom(r: Int, g: Int, b: Int)

    public func getRGB() -> (r: Int, g: Int, b: Int) {
        switch self {
        case .white:
            return (r: 255, g: 255, b: 255)

        case .black:
            return (r: 0, g: 0, b: 0)

        case .red:
            return (r: 255, g: 0, b: 0)

        case .green:
            return (r: 0, g: 255, b: 0)

        case .blue:
            return (r: 0, g: 0, b: 255)

        case .uiBlue:
            return (r: 0, g: 122, b: 255)

        case .lightBlue:
            return (r: 112, g: 166, b: 255)

        case .purple:
            return (r: 132, g: 25, b: 214)

        case .turquoise:
            return (r: 0, g: 142, b: 121)

        case .peach:
            return (r: 249, g: 229, b: 137)

        case .random:
            return (r: Int.random(in: 0 ... 255),
                    g: Int.random(in: 0 ... 255),
                    b: Int.random(in: 0 ... 255))

        case .custom(let r, let g, let b):
            return (r: r, g: g, b: b)
        }
    }

    public func interpret(nodes: [SCNNode]) {
        let color = self.getRGB()
        self.interpretColor(color.r, color.g, color.b, nodes: nodes)
    }
    
    public func getName() -> String {
        switch self {
        case .white:
            return ""
            
        case .black:
            return "black"
            
        case .red:
            return "red"
            
        case .green:
            return "green"
            
        case .blue:
            return "blue"

        case .uiBlue:
            return "UI blue"
            
        case .lightBlue:
            return "light blue"
            
        case .purple:
            return "purple"
            
        case .turquoise:
            return "turquoise"
            
        case .peach:
            return "peach"
            
        case .random:
            return "randomly-colored"
            
        case .custom(let r, let g, let b):
            return "rgb(\(r), \(g), \(b))-colored"
        }
    }

    public func getLocalName() -> String {
        switch self {
        case .white:
            return "colors.white"

        case .black:
            return "colors.black"

        case .red:
            return "colors.red"

        case .green:
            return "colors.green"

        case .blue:
            return "colors.blue"

        case .uiBlue:
            return "colors.uiBlue"

        case .lightBlue:
            return "colors.lightBlue"

        case .purple:
            return "colors.purple"

        case .turquoise:
            return "colors.turquoise"

        case .peach:
            return "colors.peach"

        default:
            return "colors.unknown";
        }
    }
    
    private func interpretColor(_ r: Int, _ g: Int, _ b: Int, nodes: [SCNNode]) {
        let trueR = CGFloat(Double(r) / 255.0)
        let trueG = CGFloat(Double(g) / 255.0)
        let trueB = CGFloat(Double(b) / 255.0)
        let color = UIColor(red: trueR, green: trueG, blue: trueB, alpha: 1.0)
        
        for node in nodes {
            recursiveInterpret(color: color, node: node)
        }
    }
    
    private func recursiveInterpret(color: UIColor, node: SCNNode) {
        for childNode in node.childNodes {
            recursiveInterpret(color: color, node: childNode)
        }
        
        node.geometry?.materials.forEach( { $0.diffuse.contents = color } )
    }
    
    public static func parseColor(text: String) -> Color? {
        let colorMap: [Color: [String]] = [
            .white:     [ "white" ],
            .black:     [ "black" ],
            .red:       [ "red" ],
            .green:     [ "green" ],
            .blue:      [ "blue" ],
            .lightBlue: [ "light-blue", "lightBlue", "sky-blue", "skyBlue" ],
            .purple:    [ "purple" ],
            .turquoise: [ "turquoise" ],
            .peach:     [ "peach", "skin" ],
            .random:    [ "random" ]
        ]
        
        for (color, names) in colorMap {
            if text.anyOf(names, ignoreCase: true) {
                return color
            }
        }
        
        if text.matches(regex: "\\d+,\\d+,\\d+") {
            let split = text.split(regex: ",")!
            
            return custom(r: Int(split[0])!.constrainTo(0, 255),
                          g: Int(split[1])!.constrainTo(0, 255),
                          b: Int(split[2])!.constrainTo(0, 255))
        }
        
        return nil
    }

    public func toUI() -> UIColor {
        let (r, g, b) = self.getRGB()
        return UIColor(red:   CGFloat(Double(r) / 255.0),
                       green: CGFloat(Double(g) / 255.0),
                       blue:  CGFloat(Double(b) / 255.0),
                       alpha: 1)
    }
    
}
