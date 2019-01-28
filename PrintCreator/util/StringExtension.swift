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
 * Useful extension methods for the String class.
 *
 * - Author:
 * Sahir Shahryar
 *
 * - Since:
 * Monday, June 4, 2018
 *
 * - Version:
 * 1.0.0
 *
 *
 * @author  Sahir Shahryar
 * @since   Monday, June 4, 2018
 * @version 1.0.0
 */

extension String {

    /**
     *
     */
    public func localize(backup: String = "", _ filler: Any...) -> String {
        return localizeNonVariadic(backup: backup, devariadize(filler))
    }


    /**
     *
     */
    public func localizeNonVariadic(backup: String = "",
                                    _ filler: [AnyObject]) -> String {
        let intermediate = Bundle.main.localizedString(forKey: self,
                                                       value: backup,
                                                       table: nil)

        return intermediate.format(filler)
    }


    /**
     *
     */
    public func format(_ args: [AnyObject]) -> String {
        var result = String(self)
        for i in 0 ..< args.count {
            let desc = String(describing: args[i])
                        .trimmingCharacters(in: CharacterSet(charactersIn: "[]{}\""))
            result = result.replacingOccurrences(of: "{\(i)}",
                                                 with: desc)
        }

        return result
    }


    /**
     *
     */
    public func index(_ i: Int) -> String.Index {
        return self.index(self.startIndex, offsetBy: i)
    }


    /**
     *
     */
    public func trim(_ chars: String) -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: chars))
    }


    /**
     *
     */
    public func trim() -> String {
        return self.trimmingCharacters(in: .whitespaces)
    }


    /**
     *
     */
    public func matches(regex: String) -> Bool {
        do {
            let blankOption = NSRegularExpression.Options(rawValue: 0)
            let blankMatchingOption = NSRegularExpression.MatchingOptions(rawValue: 0)
            
            let matcher = try NSRegularExpression(pattern: regex,
                                                  options: blankOption)
            
            let result = matcher.matches(in: self,
                                         options: blankMatchingOption,
                                         range: NSMakeRange(0, self.count))
            
            return result.count == 1
                && result[0].range.lowerBound == 0
                && result[0].range.upperBound == self.count
        } catch {
            return false
        }
    }


    /**
     *
     */
    public func split(regex: String) -> [String]? {
        return self.split(regex: regex, lim: -1)
    }


    /**
     *
     */
    public func split(regex: String, lim length: Int) -> [String]? {
        if length == 0 {
            return nil
        }
        
        if length == 1 {
            return [ self ]
        }
        
        var result = [String]()
        
        do {
            let blankOption = NSRegularExpression.Options(rawValue: 0)
            let blankMatchingOption = NSRegularExpression.MatchingOptions(rawValue: 0)
            
            let matcher = try NSRegularExpression(pattern: regex,
                                                  options: blankOption)
            let results = matcher.matches(in: self,
                                          options: blankMatchingOption,
                                          range: NSMakeRange(0, self.count))
            
            if results.count == 0 {
                return [ self ]
            }
            
            var matches = 0
            var previousEnd = self.startIndex
            for match in results {
                /**
                 * Let's be honest, string indices in Swift are utterly awful.
                 */
                var matchStart = self.startIndex
                let targetStartIndex = match.range.lowerBound
                
                let _ = self.formIndex(&matchStart,
                                       offsetBy: targetStartIndex,
                                       limitedBy: self.endIndex)
                
                result.append(String(self[previousEnd ..< matchStart]))
                
                /**
                 * God I miss unsafe string parsing. :(
                 */
                previousEnd = self.startIndex
                let _ = self.formIndex(&previousEnd,
                                       offsetBy: match.range.upperBound,
                                       limitedBy: self.endIndex)
                
                if length > 0 {
                    matches += 1
                }
                
                if matches + 1 == length {
                    result.append(String(self[previousEnd ..< self.endIndex]))
                    return result
                }
            }
            
            result.append(String(self[previousEnd ..< self.endIndex]))
            
            return result
        } catch {
            return nil
        }
    }
    

    /**
     *
     */
    public func join(_ array: [CustomStringConvertible]) -> String {
        var result = ""
        var first = true
        
        for elem in array {
            if first {
                first = false
            } else {
                result += self
            }
            
            result += elem.description
        }
        
        return result
    }


    /**
     *
     */
    public func rotateLeft(_ amount: Int) -> String {
        let rot = Int16(amount % 8)
        
        if rot == 0 {
            return String(self)
        }
        
        let bytes = Array(self.utf8)
        var result = ""
        
        for byte in bytes {
            let shiftSpace = UInt16(byte)
            let rotation = shiftSpace << rot
            
            let crop = UInt8(rotation)
            let excess = UInt8(rotation >> 8)
            
            let rotatedByte = crop | excess
            
            result += String(Character(UnicodeScalar(rotatedByte)))
        }
        
        return result
    }


    /**
     *
     */
    public func rotateRight(_ amount: Int) -> String {
        let rot = Int16(amount % 8)
        
        if rot == 0 {
            return String(self)
        }
        
        let bytes = Array(self.utf8)
        var result = ""
        
        for byte in bytes {
            let shiftSpace = UInt16(byte) << 8
            let rotation = shiftSpace >> rot

            let mask = UInt16(0b11111111_00000000)
            
            let crop = UInt8(rotation)
            let excess = UInt8((rotation & mask) >> 8)
            
            let rotatedByte = crop | excess
            
            result += String(Character(UnicodeScalar(rotatedByte)))
        }
        
        return result
    }


    /**
     *
     */
    private func equalTo(_ other: String, ignoreCase: Bool) -> Bool {
        return ignoreCase ? (self == other)
                          : self.lowercased() == other.lowercased()
    }
    

    /**
     *
     */
    public func anyOf(_ right: [String], ignoreCase: Bool = false) -> Bool {
        for option in right {
            if self.equalTo(option, ignoreCase: ignoreCase) {
                return true
            }
        }
        
        return false
    }
    

    /**
     *
     */
    public func noneOf(_ right: [String], ignoreCase: Bool = false) -> Bool {
        for option in right {
            if self.equalTo(option, ignoreCase: ignoreCase) {
                return false
            }
        }
        
        return true
    }
    
}


/**
 *
 */
public extension Array where Element == String {

    /**
     *
     */
    public func joinedRange(separator: String,
                            leftTrim: Int = 0, rightTrim: Int = 0) -> String {
        let start = leftTrim, end = self.count - rightTrim
        return self.joinedRange(separator: separator, min: start, max: end)
    }


    /**
     *
     */
    public func joinedRange(separator: String,
                            min: Int = 0, max: Int = 0) -> String {
        var start = min, end = max
        if start > end {
            let temp = start
            start = end
            end = temp
        }

        if start > self.count || end < 1 {
            return ""
        }

        let range = (start ..< end).clamped(to: 0 ..< self.count + 1)

        var result = ""
        var first = true
        for i in range {
            if first {
                first = false
            } else {
                result += separator
            }

            result += self[i]
        }

        return result
    }
    
}
