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
 * Represents a title bar which has both a title and a subtitle underneath it.
 * Surprisingly, this is *not* native functionality in UIKit.
 *
 * - author:  Sahir Shahryar
 * - since:   Sunday, July 8, 2018
 * - version: 1.0.0
 */
public class SubtitleView: UIView {

    /**
     * Hey, I finally found a use for `get` and `set`! Represents the title text of this
     * title bar.
     */
    public var title: String? {
        get {
            return self.titleLabel?.text
        }

        set (newValue) {
            self.titleLabel?.text = newValue
        }
    }


    /**
     * Represents the subtitle text of this title bar.
     */
    public var subtitle: String? {
        get {
            return self.subtitleLabel?.text
        }

        set (newValue) {
            self.subtitleLabel?.text = newValue
        }
    }


    /**
     * This is the actual `UILabel` that represents the title shown in the view.
     */
    private var titleLabel: UILabel? = nil


    /**
     * This is the `UILabel` that represents the subtitle shown in the view.
     */
    private var subtitleLabel: UILabel? = nil


    /**
     * Initializes this `SubtitleView` with the given `CGRect` as its frame.
     *
     * - parameter frame: `(CGRect)` the bounding box for this `SubtitleView`.
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.establishTitles()
    }


    /**
     * Initializes this `SubtitleView` from a given `NSCoder`.
     *
     * - parameter coder: `(NSCoder)` the decoder used to create this `SubtitleView`.
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.establishTitles()
    }


    /**
     * Establishes the title and subtitle views.
     */
    private func establishTitles() {
        /**
         * First and foremost, the title.
         */
        titleLabel = UILabel()
        titleLabel!.font = titleLabel!.font.boldfaced()
        titleLabel!.textAlignment = .center

        
        titleLabel!.text = " "
        titleLabel!.sizeToFit()
        titleLabel!.frame = CGRect(x: 0, y: 0,
                                   width: self.frame.width,
                                   height: titleLabel!.frame.height)

        /**
         * Second, the subtitle.
         */
        subtitleLabel = UILabel()
        subtitleLabel!.font = UIFont.systemFont(ofSize: 0.75 * titleLabel!.font.pointSize)
        subtitleLabel!.textAlignment = .center

        subtitleLabel!.text = " "
        subtitleLabel!.sizeToFit()
        subtitleLabel!.frame = CGRect(x: 0,
                                      y: titleLabel!.frame.maxY + 2,
                                      width: self.frame.width,
                                      height: subtitleLabel!.frame.height)

        self.addSubview(titleLabel!)
        self.addSubview(subtitleLabel!)
    }

}
