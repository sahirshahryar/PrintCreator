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
 * Represents the history of edits made on a block.
 *
 * - author:  Sahir Shahryar
 * - since:   Tuesday, June 26, 2018
 * - version: 1.0.0
 */
public class EditHistory {
    
    /**
     * This constant represents the number of edits that can be stored in the edit
     * history. The edit history itself can be stored in the background if the user
     * desires.
     */
    public static let HISTORY_SIZE = 128
    
    
    /**
     * The actual list of edits being made. This data structure functions much like
     * a queue based on an array, keeping track of a "head" where the most recent
     * edit was added. The stored type of `history` is `[Edit]?` because we store
     * *groups* of edits (for user convenience with the Undo / Redo buttons when making
     * mass adjustments) and because the history has a fixed size, meaning that some
     * array indices may need to be `nil`, especially for a short while after the edit
     * history has just been established.
     */
    private var history: [[Edit]?]
    
    
    /**
     * The position of the most recent edit in the history. This is a technical-level
     * variable, needed to properly add and remove elements from the history.
     */
    private var pos: Int
    
    
    /**
     * The position of the "cursor" in the history. As the user taps the "Undo" and "Redo"
     * buttons, this value will increase and decrease.
     */
    private var cursor: Int
    
    
    /**
     * Initializes the `EditHistory`.
     */
    public init() {
        self.history = [[Edit]?](repeating: nil, count: EditHistory.HISTORY_SIZE)
        self.pos = EditHistory.HISTORY_SIZE - 1
        self.cursor = EditHistory.HISTORY_SIZE - 1
    }
    
    
    /**
     * Adds the given edits as a group to the edit history.
     *
     * - parameter edits: `([Edit])` the group of `Edit`s to be added to the history.
     */
    public func add(edits: [Edit]) {
        /**
         * If some undo operations have been done before making this edit, the cursor will
         * not be at the same position as the actual barricade separating the top of the
         * edit history from the bottom. All of the elements between the barricade and the
         * cursor need to be cleared as a result.
         */
        var cleanupPerformed = false
        while self.pos != self.cursor {
            self.history[self.pos] = nil
            self.pos = nextPos()
            cleanupPerformed = true
        }

        if cleanupPerformed {
            self.pos = prevPos()
        }

        /**
         * The 
         */
        self.history[self.pos] = edits
        self.pos = prevPos()
        
        self.cursor = self.pos
    }
    

    /**
     *
     */
    public func add(_ edit: Edit) {
        self.add(edits: [ edit ])
    }


    /**
     *
     */
    public func canUndo() -> Bool {
        /**
         * First iterate through the array and see if there are any elements that are not
         * `nil`. If there are, make sure that the current cursor position is not backed
         * up against the
         */
        for edit in self.history {
            if edit != nil {
                return nextCursor() != self.pos
            }
        }
        
        /**
         * No non-`nil` elements in the entire `history` array? Then no undo is available.
         */
        return false
    }


    /**
     *
     */
    public func canRedo() -> Bool {
        return self.pos != self.cursor
    }


    /**
     *
     */
    public func undo() throws -> [Edit] {
        if !canUndo() {
            throw HistoryError.undoUnavailable
        }
        
        guard let edits = self.history[self.cursor] else {
            throw HistoryError.undoUnavailable
        }

        self.cursor = nextCursor()
        return edits
    }


    /**
     *
     */
    public func redo() throws -> [Edit] {
        if !canRedo() {
            throw HistoryError.redoUnavailable
        }

        self.cursor = prevCursor()

        guard let edits = self.history[self.cursor] else {
            throw HistoryError.redoUnavailable
        }

        return edits
    }


    /**
     *
     */
    private func nextCursor() -> Int {
        var candidate = self.cursor
        
        repeat {
            candidate += 1
            
            if candidate == EditHistory.HISTORY_SIZE {
                candidate = 0
            }
            
            // We looped all the way back around
            if candidate == self.cursor {
                return EditHistory.HISTORY_SIZE
            }
        } while self.history[candidate] == nil
        
        return candidate
    }


    /**
     *
     */
    private func prevCursor() -> Int {
        var candidate = self.cursor
        
        repeat {
            candidate -= 1
            
            if candidate < 0 {
                candidate = EditHistory.HISTORY_SIZE - 1
            }
            
            if candidate == self.cursor {
                return EditHistory.HISTORY_SIZE
            }
        } while self.history[candidate] == nil
        
        return candidate
    }
    
    
    /**
     *
     */
    private func nextPos() -> Int {
        if self.pos == EditHistory.HISTORY_SIZE - 1 {
            return 0
        }
        
        return self.pos + 1
    }


    /**
     *
     */
    private func prevPos() -> Int {
        if self.pos == 0 {
            return EditHistory.HISTORY_SIZE - 1
        }
        
        return self.pos - 1
    }
    
}


/**
 *
 */
public enum HistoryError: Error {
    case undoUnavailable
    case redoUnavailable
}
