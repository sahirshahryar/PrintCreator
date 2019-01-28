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

/**
 * @author  Sahir Shahryar
 * @since   Monday, June 4, 2018
 * @version 1.0.0
 */
import Foundation

/**
 * 
 */
private let BIT_SHIFT_OUTPUT = false


/**
 *
 */
private let BIT_SHIFT_FACTOR = 1

/**
 * Creates a Component object from the given MDL (.mdl) file.
 *
 *
 */
public func createComponent(_ filename: String,
                            knownBlockTypes: [String]) throws -> Component  {
    if !filename.hasSuffix(".mdl") {
        throw MDLParseError.illegalFileType(filename: filename)
    }
    
    /**
     *
     */
    do {
        var contents = try String(contentsOfFile: filename)
        
        if BIT_SHIFT_OUTPUT {
            contents = contents.rotateRight(BIT_SHIFT_FACTOR)
        }
        
        let lines    = contents.components(separatedBy: .newlines)
        
        let result = Component()
        var aliases = [String: String]()
        
        /**
         *
         */
        var lineNumber = 0
        var lastInstructionAutopeg = false
        for line in lines {
            lineNumber += 1
            
            if line == "" || line.hasPrefix("#") {
                continue
            }
            
            /**
             *
             */
            if line.hasPrefix("let") {
                guard let tokens = line.split(regex: "( *= *| )") else {
                    throw MDLParseError.invalidAliasDefinition(line: line,
                                                               lineNo: lineNumber)
                }
                
                //
                if tokens.count != 3 {
                    print("\(tokens.count) elements")
                    throw MDLParseError.invalidAliasDefinition(line: line,
                                                               lineNo: lineNumber)
                }
                
                let variableName = tokens[1]
                
                // Illegal variable names, let and autopeg.
                if variableName.anyOf([ "let", "autopeg", "@" ]) {
                    throw MDLParseError.illegalAliasName(name: variableName,
                                                         lineNo: lineNumber)
                }
                
                if variableName.anyOf(knownBlockTypes) {
                    throw MDLParseError.cannotUseBlockName(name: variableName,
                                                           lineNo: lineNumber)
                }
                
                //
                if aliases.keys.contains(variableName) {
                    throw MDLParseError.aliasAlreadyUsed(name: variableName,
                                                         lineNo: lineNumber)
                }
                
                let variableValue = tokens[2]
                
                //
                if variableName == variableValue {
                    throw MDLParseError.recursiveAliasName(line: line,
                                                           lineNo: lineNumber)
                }
                
                //
                if aliases.keys.contains(variableValue) {
                    throw MDLParseError.remappedAliasName(line: line,
                                                          lineNo: lineNumber)
                }
                
                //
                if !knownBlockTypes.contains(variableValue) {
                    throw MDLParseError.unknownBlockType(name: variableValue,
                                                         lineNo: lineNumber)
                }
                
                //
                aliases[variableName] = variableValue
                lastInstructionAutopeg = false
            }
            
            else if line.hasPrefix("autopeg") {
                // TODO: Automatic peg mapping
                lastInstructionAutopeg = true
            }
            
            /**
             *
             */
            else if line.contains("@") {
                if !result.hasRoot() {
                    throw MDLParseError.insertionBeforeRoot(line: line,
                                                            lineNo: lineNumber)
                }
                
                guard let tokens = line.split(regex: " *@ *", lim: 4) else {
                    throw MDLParseError.invalidBlockDefinition(line: line,
                                                               lineNo: lineNumber)
                }
                
                if tokens.count.noneOf([ 3, 4 ]) {
                    throw MDLParseError.invalidBlockDefinition(line: line,
                                                               lineNo: lineNumber)
                }
                
                let type = tokens[0]
                let trueType = aliases[type] ?? type
                
                
                // Redundant catch for unknown block type, in case no alias was used.
                if !knownBlockTypes.contains(trueType) {
                    throw MDLParseError.unknownBlockType(name: trueType,
                                                         lineNo: lineNumber)
                }
                
                let path = BlockPath(tokens[1])
                let block = BlockTypes.makeBlock(type: trueType, path: path)!
                
                if !result.isVacant(path) {
                    throw MDLParseError.duplicateBlockAddress(line: line,
                                                              lineNo: lineNumber)
                }
                
                let newBlockFace = tokens[2]
                
                if tokens.count == 4 {
                    if tokens[3] == "invisible" {
                        block.setVisible(false)
                    } else {
                        guard let color = Color.parseColor(text: tokens[3]) else {
                            throw MDLParseError.colorUnknown(name: tokens[3],
                                                             lineNo: lineNumber)
                        }
                        
                        block.setColor(color)
                    }
                }
                
                do {
                    try result.addBlock(block, newBlockFace: newBlockFace)
                    lastInstructionAutopeg = false
                } catch let error as BlockAdditionError {
                    throw MDLParseError
                          .blockAdditionFailed(line: line,
                                               lineNo: lineNumber,
                                               error: Component.getErrorMessage(error))
                }
            }
            
            /**
             *
             */
            else {
                if result.hasRoot() {
                    throw MDLParseError.duplicateRootDefinition(line: line,
                                                                lineNo: lineNumber)
                }
                
                let tokens = line.split(regex: ":", lim: 2)!
                
                let trueType = aliases[tokens[0]] ?? line
                
                if !knownBlockTypes.contains(trueType) {
                    throw MDLParseError.unknownBlockType(name: trueType,
                                                         lineNo: lineNumber)
                }
                
                let block = BlockTypes.makeBlock(type: trueType)!
                
                if tokens.count == 2 {
                    if tokens[1] == "invisible" {
                        block.setVisible(false)
                    } else {
                        guard let color = Color.parseColor(text: tokens[1]) else {
                            throw MDLParseError.colorUnknown(name: tokens[1],
                                                             lineNo: lineNumber)
                        }
                        
                        block.setColor(color)
                    }
                }
                
                result.establishRoot(block)
                lastInstructionAutopeg = false
            }
        }
        
        return result
    } catch let error {
        if error is MDLParseError {
            throw error
        }
        
        throw MDLParseError.fileAccessError(filename: filename)
    }
}


/**
 *
 */
public func describeComponent(_ component: Component) throws {
    var aliases = [String: String]()
    
    let freqMap = frequencyMap(objects: component.getBlocks(),
                               property: { $0.getType() })
    
    var alias = 0
    for blockType in frequencyMapIterator(map: freqMap) {
        if freqMap[blockType]! > 1 {
            alias += 1
            aliases[blockType] = String(alias)
        }
    }
}


/**
 *
 */
private func error(_ lineNo: Int) -> String {
    return "mdl-parse-error.number-only".localize(lineNo)
}


/**
 *
 */
private func error(_ line: String, _ lineNo: Int) -> String {
    return "mdl-parse-error.number-and-text".localize(lineNo, line)
}


/**
 *
 */
public enum MDLParseError: Error {
    /**
     * This error is thrown when the file given to the MDL parser is not an `.mdl` file.
     *
     * - parameter filename: `(String)` the name of the file that was given to the parser.
     */
    case illegalFileType           (filename: String)

    /**
     * This error is thrown if the given file *is* an `.mdl` file, but doesn't exist or
     * cannot be read.
     *
     * - parameter filename: `(String)` the name of the file that was given to the parser.
     */
    case fileAccessError           (filename: String)

    /**
     * This error is thrown when an alias is not defined correctly due to a syntax error.
     *
     * - parameters:
     *     - line: `(String)` the full text of the line on which the error occurred.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case invalidAliasDefinition    (line: String, lineNo: Int)

    /**
     * This error is thrown when an alias name is reused.
     *
     * - parameters:
     *     - name: `(String)` the name of the reused alias.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case aliasAlreadyUsed          (name: String, lineNo: Int)

    /**
     * This error is thrown when an illegal alias name is used. Illegal alias names
     * include `let` (used to define aliases), `autopeg` (special command to add pegs
     * to the model past a certain point), and `@` (character that separates the different
     * components of each instruction).
     *
     * - parameters:
     *     - name: `(String)` the name of invalid alias.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case illegalAliasName          (name: String, lineNo: Int)

    /**
     * This error is thrown when an alias tries to map to another alias. Aliases must
     * point directly to a block type; the parser does not attempt to resolve aliases
     * repeatedly.
     *
     * - parameters:
     *     - line: `(String)` the full text of the line on which the error occurred.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case remappedAliasName         (line: String, lineNo: Int)

    /**
     * This error is thrown when an alias tries to map to itself. Aliases must not point
     * to themselves.
     *
     * - parameters:
     *     - line: `(String)` the full text of the line on which the error occurred.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case recursiveAliasName        (line: String, lineNo: Int)


    /**
     * This error is thrown when the `.mdl` file tries to use the name of a known block
     * type as the name of an alias.
     *
     * - parameters:
     *     - name: `(String)` the name of the variable.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case cannotUseBlockName        (name: String, lineNo: Int)

    /**
     * This error is thrown when the `.mdl` file tries to insert a block before the
     * root block was defined.
     *
     * - parameters:
     *     - line: `(String)` the full text of the line on which the error occurred.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case insertionBeforeRoot       (line: String, lineNo: Int)

    /**
     * This error is thrown when a block insertion instruction is not formatted correctly.
     * The correct format is `[type|alias]@[path]@[newBlockFace]`.
     *
     * - parameters:
     *     - line: `(String)` the full text of the line on which the error occurred.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case invalidBlockDefinition    (line: String, lineNo: Int)

    /**
     * This error is thrown when a block insertion instruction specifies a block type that
     * doesn't exist.
     *
     * - parameters:
     *     - name: `(String)` the name of the block type that doesn't exist.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case unknownBlockType          (name: String, lineNo: Int)


    /**
     * This error is thrown when the color specified for a block cannot be parsed into a
     * `Color` value.
     *
     * - parameters:
     *     - name: `(String)` the name of the color that doesn't exist.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case colorUnknown              (name: String, lineNo: Int)

    /**
     * This error is thrown when a block insertion instruction tries to specify a block at
     * a position that is already taken.
     *
     * - parameters:
     *     - line: `(String)` the full text of the line on which the error occurred.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case duplicateBlockAddress     (line: String, lineNo: Int)

    /**
     * This error is thrown when the block specified by an instruction cannot be inserted
     * for some reason (which is given by `Component`'s `addBlock()` method).
     *
     * - parameters:
     *     - line: `(String)` the full text of the line on which the error occurred.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     *     - error: `(String)` the error message given from `Component`'s `addBlock()`
     *              method.
     */
    case blockAdditionFailed       (line: String, lineNo: Int, error: String)

    /**
     * This error is thrown when the given block insertion is systematically (valid block
     * address and all), but not physically, possible.
     *
     * - parameters:
     *     - line: `(String)` the full text of the line on which the error occurred.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case blockCollision            (line: String, lineNo: Int)

    /**
     * This error is thrown when the `.mdl` file tries to specify more than one root
     * block.
     *
     * - parameters:
     *     - line: `(String)` the full text of the line on which the error occurred.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case duplicateRootDefinition   (line: String, lineNo: Int)

    /**
     * This error is thrown when the `autopeg` instruction cannot be run because it's too
     * early (or because it was *just* run).
     *
     * - parameters:
     *     - line: `(String)` the full text of the line on which the error occurred.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case autopegNotApplicable      (line: String, lineNo: Int)

    /**
     *
     * - parameters:
     *     - name: `(String)` the name of the argument that was given to `autopeg`.
     *     - lineNo: `(Int)` the line number of the line on which the error occurred.
     */
    case illegalAutopegArgument    (name: String, lineNo: Int)


    /**
     *
     */
    public func getMessage() -> String {
        switch self {
        case .illegalFileType(let filename):
            return "mdl-parse-error.illegalFileType".localize(filename)

        case .fileAccessError(let filename):
            return "mdl-parse-error.fileAccessError".localize(filename)

        case .invalidAliasDefinition(let line, let lineNo):
            return error(line, lineNo)
                 + "mdl-parse-error.invalidAliasDefinition".localize()

        case .aliasAlreadyUsed(let name, let lineNo):
            return error(lineNo)
                 + "mdl-parse-error.aliasAlreadyUsed".localize(name)

        case .illegalAliasName(let name, let lineNo):
            return error(lineNo)
                 + "mdl-parse-error.illegalAliasName".localize(name)

        case .remappedAliasName(let line, let lineNo):
            return error(line, lineNo)
                 + "mdl-parse-error.remappedAliasName".localize()

        case .recursiveAliasName(let line, let lineNo):
            return error(line, lineNo)
                 + "mdl-parse-error.recursiveAliasName".localize()

        case .cannotUseBlockName(let name, let lineNo):
            return error(lineNo)
                 + "mdl-parse-error.cannotUseBlockName".localize(name)

        case .insertionBeforeRoot(let line, let lineNo):
            return error(line, lineNo)
                 + "mdl-parse-error.insertionBeforeRoot".localize()

        case .invalidBlockDefinition(let line, let lineNo):
            return error(line, lineNo)
                 + "mdl-parse-error.invalidBlockDefinition".localize()

        case .unknownBlockType(let name, let lineNo):
            return error(lineNo)
                 + "mdl-parse-error.unknownBlockType".localize(name)

        case .colorUnknown(let name, let lineNo):
            return error(lineNo)
                 + "mdl-parse-error.colorUnknown".localize(name)

        case .duplicateBlockAddress(let line, let lineNo):
            return error(line, lineNo)
                 + "mdl-parse-error.duplicateBlockAddress".localize()

        case .blockCollision(let line, let lineNo):
            return error(line, lineNo)
                 + "mdl-parse-error.blockCollision".localize()

        case .blockAdditionFailed(let line, let lineNo, let errorMessage):
            return error(line, lineNo)
                 + "mdl-parse-error.blockAdditionFailed".localize(errorMessage)

        case .duplicateRootDefinition(let line, let lineNo):
            return error(line, lineNo)
                 + "mdl-parse-error.duplicateRootDefinition".localize()

        case .autopegNotApplicable(let line, let lineNo):
            return error(line, lineNo)
                 + "mdl-parse-error.autopegNotApplicable".localize()

        case .illegalAutopegArgument(let name, let lineNo):
            return error(lineNo)
                 + "mdl-parse-error.illegalAutopegArgument".localize(name)

        }
    }
}
