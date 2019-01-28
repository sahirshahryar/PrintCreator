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
 * Represents an iterator which can go through all of the given binary permutations
 * from 0 to 2^n - 1, where n is the number of bits specified.
 *
 * - author:  Sahir Shahryar
 * - since:   Tuesday, June 26, 2018
 * - version: 1.0.0
 */
public struct BinaryPermutation: Sequence {

    /**
     * The number of bits being permuted.
     */
    fileprivate let size: Int


    /**
     * 
     */
    init(bits size: Int) {
        self.size = size
    }

    public func makeIterator() -> BinaryPermutationIterator {
        return BinaryPermutationIterator(self)
    }

}


/**
 *
 */
public class BinaryPermutationIterator: IteratorProtocol {
    public typealias Element = [Bool]

    private var iter: UInt64
    private let size: Int
    private let max: UInt64

    private var complete: Bool

    init(_ perm: BinaryPermutation) {
        self.size = perm.size
        self.max = pow2(self.size)
        self.iter = 0
        self.complete = false
    }

    public func next() -> [Bool]? {
        if self.complete {
            return nil
        }

        if self.iter + 1 == 0 || self.iter + 1 == self.max {
            self.complete = true
            return [Bool](repeating: true, count: self.size)
        }

        var result = [Bool](repeating: false, count: self.size)

        for i in 0 ..< self.size {
            result[self.size - i - 1] = (iter & (1 << i)) != 0
        }

        self.iter += 1

        return result
    }

}


/**
 *
 */
public func pow2(_ pow: Int) -> UInt64 {
    return 1 << pow
}
