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


/**
 *
 * - author:  Sahir Shahryar
 * - since:   Monday, June 25, 2018
 * - version: 1.0.0
 */
public class FileInterface {

    /**
     *
     */
    public static let USER_MODELS_STORAGE = "usermodels"


    /**
     *
     */
    public static let PRESET_STORAGE = "presets"


    /**
     *
     */
    public static func listFiles(folder: String = USER_MODELS_STORAGE) -> [String] {
        let resourceFolder = Bundle.init(for: self)
        
        guard let folder = resourceFolder.path(forResource: folder, ofType: nil) else {
            return []
        }
                
        var result = [String]()
        
        let fileManager = FileManager.default
        
        do {
            for file in try fileManager.contentsOfDirectory(atPath: folder) {
                if file.hasSuffix(".mdl") {
                    result.append(file)
                }
            }
        } catch {
            return []
        }
        
        return result
    }
    
}
