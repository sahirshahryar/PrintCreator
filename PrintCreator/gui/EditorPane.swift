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
import UIKit


/**
 * Represents the editor pane which appears underneath the model itself.
 *
 * - author:  Sahir Shahryar
 * - since:   Tuesday, July 3, 2018
 * - version: 1.0.0
 */
public class EditorPane: UIViewController {

    /**
     * Represents the parent `Viewport`, information from which may be useful for
     * some of `EditorPane`'s functions.
     */
    public weak var parentView: Viewport?


    /**
     * Determines the width of the editor pane, which is 375 pt. on an iPad or the full
     * width of the screen on an iPhone.
     */
    public static let WIDTH = isTablet()
                            ? CGFloat(375)
                            : UIScreen.main.bounds.width

    /**
     * Represents the minimum height of the window above the bottom margin. Minimum of 56
     * pt., plus the bottom margin (34 pt. on iPhone X). This property is not applicable
     * to the iPad version of the app.
     *
     * If this crashes (thanks to `keyWindow!`), rip.
     */
    public static let MIN_HEIGHT = CGFloat(56)
                                 + UIApplication.shared.keyWindow!.safeAreaInsets.bottom


    /**
     * Represents the maximum height of the editor pane above `EditorPane.MIN_HEIGHT`.
     * 250 pt. by default.
     */
    public var maxHeight = CGFloat(250)


    /**
     * Represents the base length for how long animations take to complete. Animations
     * will never complete faster than this time.
     */
    public static let ANIMATION_TIME = CGFloat(0.2)


    /**
     * Represents the maximum distance past `maxHeight` that the editor pane can be pulled
     * up before it pulls up no further.
     */
    public static let FRICTION_DISTANCE = CGFloat(30)


    /**
     * Whether or not the model belonging to `parentView` is editable (i.e., is it a
     * preset or a user-built model?). If `editingPermitted` is `true`, the user will see
     * the standard editor toolkit; otherwise, a message will appear warning the user that
     * the model needs to be cloned before it can be edited.
     */
    public var editingPermitted: Bool = true


    /**
     * A dictionary of UI elements. This is useful for animating the opacity of various
     * UI elements as the editor pane is scrolled up and down. Since the layout changes
     * based on whether `editingPermitted` is `true` or `false`, having a dynamic
     * dictionary instead of a variable for each element is quite useful.
     */
    public var uiElements = [EditorPaneElement: UIView]()


    /**
     * The `move` value of the last `UIPanGestureRecognizer` sent before a
     * `UIPanGestureRecognizer` with the state `.ended` is sent. This allows us to store
     * the "flickiness" of the pan gesture for use when the pan gesture ends, since
     * a `UIPanGestureRecognizer` with the state `.ended` has a `move` value of
     * `CGPoint(x: 0, y: 0)`. The time of the last update of `flick.dir` is also stored,
     * so that we can keep the maximum flick value in a short period (in case a high-
     * intensity flick is overwritten in the last 150 or so milliseconds of the flick
     * gesture).
     *
     * This value is not `nil` only during the length of a pan gesture; at all other
     * times, it is `nil`.
     */
    private var flick: (dir: CGPoint, time: UInt64)? = nil


    /**
     * Whether or not the editor pane is in its expanded state.
     */
    private var isExpanded = false


    /**
     * The invisible rectangle which can be tapped to expand or collapse the editor pane.
     * This rectangle resides at the top of the editor pane, where the title "Edit" or
     * "Editing unavailable" is shown.
     */
    private var expanderFrame: CGRect? = nil


    /**
     * Describes the degree to which the editor pane is expanded, as a percentage. Good
     * for editor panes of unknown height.
     *
     * - returns: `(CGFloat)` a value between `0.0` (entirely collapsed) and `1.0`
     *            (entirely expanded).
     */
    public func unfurlance() -> CGFloat {
        let minY = UIScreen.main.bounds.height - maxHeight
        let maxY = UIScreen.main.bounds.height - EditorPane.MIN_HEIGHT

        let currentY = self.view.frame.minY
        let currentDistance = maxY - currentY
        let maxDistance = maxY - minY
        return (currentDistance / maxDistance).constrainTo(0, 1)
    }


    /**
     * Describes the degree to which the editor pane is expanded, as the raw number of
     * pixels. Good for triggering effects at a specific height.
     *
     * - returns: `(CGFloat)` the height of the current editor pane above its minimum
     *            height, in pixels.
     */
    public func rawUnfurlance() -> CGFloat {
        let maxY = UIScreen.main.bounds.height - EditorPane.MIN_HEIGHT
        let currentY = self.view.frame.minY
        return maxY - currentY
    }


    /**
     * Handles the setup of the editor pane's elements.
     */
    public override func viewDidLoad() {
        super.viewDidLoad()

        if editingPermitted {
            self.loadEditorElements()
        } else {
            self.loadCloneMessage()
        }

        let swipe = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.view.addGestureRecognizer(swipe)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tap)
    }


    public override func viewDidLayoutSubviews() {
        let f = self.view.frame
        self.view.frame = CGRect(x: f.minX, y: f.minY, width: f.width,
                                 height: maxHeight + 120)
    }


    /**
     * Loads the editor pane that is presented when `editingPermitted` is `true`.
     */
    private func loadEditorElements() {
        let headingLabel = self.createHeader(text: "editor-pane.title")

        // First, the block picker.
        var newY = headingLabel.frame.maxY + 20
        let blockPicker = BlockChooser()
        blockPicker.setY(newY)

        if !isTablet() {
            blockPicker.alpha = 0
        }

        self.view.addSubview(blockPicker)
        self.uiElements[.blockPicker] = blockPicker

        // Next, the color picker.
        newY = blockPicker.frame.maxY + 10
        let colorPicker = ColorChooser()
        colorPicker.setY(newY)

        if !isTablet() {
            colorPicker.alpha = 0
        }

        self.view.addSubview(colorPicker)
        self.uiElements[.colorPicker] = colorPicker

        self.maxHeight = colorPicker.frame.maxY + 16 + EditorPane.FRICTION_DISTANCE
    }


    /**
     * Loads the editor pane that is presented when `editingPermitted` is `false`.
     */
    private func loadCloneMessage() {
        /**
         * First, establish the heading label.
         */
        let headingLabel = self.createHeader(text: "editor-pane.title-disabled")

        /**
         * Add a description of why editing is unavailable to the user.
         */
        let explanation = UILabel()
        explanation.frame = CGRect(x: 20,
                                   y: headingLabel.frame.maxY + 8,
                                   width: EditorPane.WIDTH * 0.67,
                                   height: 32)

        explanation.numberOfLines = 3
        explanation.text = "editor-pane.unavailable-desc".localize()
        explanation.textColor = UIColor.darkGray
        explanation.font = UIFont.systemFont(ofSize: 0.8 * headingLabel.font.pointSize)
        explanation.sizeToFit()

        if !isTablet() {
            explanation.alpha = 0
        }

        explanation.isAccessibilityElement = true
        explanation.accessibilityTraits = UIAccessibilityTraitStaticText
        explanation.accessibilityLabel = "editor-pane.unavailable-desc".localize()

        self.view.addSubview(explanation)
        self.uiElements[.explanation] = explanation

        /**
         * Add the button to make a copy of this model.
         */
        let cloneButton = CloneButton()
        cloneButton.frame = CGRect(x: 20,
                                   y: explanation.frame.maxY + 16,
                                   width: EditorPane.WIDTH * 0.4,
                                   height: 36)

        cloneButton.backgroundColor = Color.uiBlue.toUI()
        cloneButton.layer.cornerRadius = 4

        let title: String
        if let filename = self.parentView?.filename {
            let stylizedFilename = filename.trim("/") + ".mdl"
            title = "editor-pane.make-named-clone".localize(stylizedFilename)
        } else {
            title = "editor-pane.make-clone".localize()
        }

        cloneButton.setTitle(title, for: .normal)

        let fontSize = cloneButton.titleLabel!.font.pointSize
        cloneButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 0.7 * fontSize)

        /**
         * A bit of a nasty hack -- start by sizing the button to fit (which determines
         * the minimum required frame size), then resize the frame to add a little bit of
         * padding on the sides.
         */
        cloneButton.sizeToFit()
        cloneButton.frame = CGRect(x: 20,
                                   y: cloneButton.frame.minY,
                                   width: cloneButton.frame.width + 16,
                                   height: 36)

        if !isTablet() {
            cloneButton.alpha = 0
        }

        cloneButton.isAccessibilityElement = true
        cloneButton.accessibilityTraits = UIAccessibilityTraitButton
        cloneButton.accessibilityLabel = title

        self.view.addSubview(cloneButton)
        self.uiElements[.cloneButton] = cloneButton

        /**
         * Finally, establish the maximum height.
         */
        self.maxHeight = cloneButton.frame.maxY + 16 + EditorPane.FRICTION_DISTANCE
    }


    /**
     * Creates the title header for the editor pane with the given title and (optionally)
     * custom accessibility text.
     *
     * - parameters:
     *   - text: `(String)` the localization key of the text that will be contained in the
     *           header.
     *   - accessibility: `(String? = nil)` the custom accessibility text for the given
     *                    button; set to `text` if `nil` or not specified.
     *
     * - returns: `(UILabel)` the header label for use inside `loadEditorElements()` and
     *            `loadCloneMessage()` so that they don't have to use the risky-looking
     *            statement `self.uiElements["heading"]! as! UILabel`.
     */
    private func createHeader(text label: String,
                              accessibility: String? = nil) -> UILabel {
        let headingLabel = UILabel()
        headingLabel.frame = CGRect(x: 20,
                                    y: 20,
                                    width: EditorPane.WIDTH / 2,
                                    height: 32)

        headingLabel.text = label.localize()
        headingLabel.textColor = UIColor.black
        headingLabel.font = UIFont.boldSystemFont(ofSize: headingLabel.font.pointSize)

        /**
         * God I love Swift's syntactic sugar. `(accessibility ?? label).localize()`? So
         * damn clean.
         */
        headingLabel.isAccessibilityElement = true
        headingLabel.accessibilityTraits = UIAccessibilityTraitStaticText
        headingLabel.accessibilityLabel = (accessibility ?? label).localize()

        headingLabel.sizeToFit()

        /**
         * Prepare the element for scrolling. The editor pane cannot be scrolled in or out
         * on iPads, so the button and the transparency effect below are only necessary on
         * the iPhone.
         */
        if !isTablet() {
            headingLabel.alpha = 0.6
            self.expanderFrame = CGRect(x: 0, y: 0, width: EditorPane.WIDTH,
                                        height: headingLabel.frame.maxY + 16)
        }

        self.view.addSubview(headingLabel)
        self.uiElements[.heading] = headingLabel

        return headingLabel
    }


    /**
     * Describes the correct alpha values for the current scrolling position. This creates
     * nice transitions as the editor pane scrolls up and down, and ensures that text
     * isn't randomly clipping off the edge of the screen or (most awfully) clipping into
     * the safe area on the iPhone X.
     *
     * Element opacities do not change on the iPad, which does not have a scrollable
     * editor pane.
     */
    private func handleElementOpacities() {
        if isTablet() {
            return
        }

        let unfurlance = self.unfurlance()

        if let heading = self.uiElements[.heading] {
            heading.alpha = (3 * unfurlance).constrainTo(0.6, 1)
        }

        /**
         * The elements that need to be animated will be different when `editingPermitted`
         * is `true` and when it's `false`.
         */
        if editingPermitted {
            if let blockPicker = self.uiElements[.blockPicker] {
                blockPicker.alpha = (2 * (unfurlance - 0.5)).constrainTo(0, 1)
            }

            if let colorChooser = self.uiElements[.colorPicker] {
                colorChooser.alpha = (3 * (unfurlance - 0.66)).constrainTo(0, 1)
            }
        }

        /**
         *
         */
        else {

            if let explanation = self.uiElements[.explanation] {
                explanation.alpha = (2 * unfurlance).constrainTo(0, 1)
            }

            if let cloneButton = self.uiElements[.cloneButton] {
                cloneButton.alpha = (2 * (unfurlance - 0.5)).constrainTo(0, 1)
            }
        }
    }


    /**
     * Animates the editor pane to a fully-extended position. Useful when flicking and
     * tapping the expand button.
     *
     * - parameters:
     *   - doRubberband: `(Bool)`  whether or not a rubberbanding animation should be
     *                   played.
     *   - intensity: `(CGFloat)` the intensity with which the flick upwards occurred.
     *                This should be a value between 0 (lazy flick) and 1 (intense flick).
     *                The closer the value is to 1, the faster the flick upwards will
     *                occur.
     */
    func flickUp(doRubberband: Bool, intensity: CGFloat) {
        func completeAnimation(completed: Bool) {
            UIView.animate(withDuration: Double(EditorPane.ANIMATION_TIME),
                           animations: {
                let top = UIScreen.main.bounds.maxY
                        - self.maxHeight

                self.view.frame = CGRect(x: 0, y: top,
                                         width: self.view.frame.width,
                                         height: self.view.frame.height)

                self.handleElementOpacities()
            })
        }

        if doRubberband {
            UIView.animate(withDuration: Double(EditorPane.ANIMATION_TIME /
                                                intensity.constrainTo(0.5, 1)),
                           delay: 0,
                           options: .curveLinear,

            animations: {
                let top = UIScreen.main.bounds.maxY
                        - self.maxHeight
                        - (EditorPane.FRICTION_DISTANCE / 3)
                        - (10 * intensity.constrainTo(0.5, 1))

                self.view.frame = CGRect(x: 0, y: top,
                                         width: self.view.frame.width,
                                         height: self.view.frame.height)

                self.handleElementOpacities()
            },

            completion: completeAnimation(completed:))
        }

        else {
            completeAnimation(completed: true)
        }

        self.isExpanded = true
    }


    /**
     * Animates the editor pane into its collapsed position. Normally used when the user
     * flicks the editor pane downwards or taps it to collapse it, but also used to bring
     * the editor pane into view from underneath the bottom of the screen.
     *
     * - parameter intensity: `(CGFloat)` the intensity with which the flick upwards
     *                         occurred. This should be a value between 0 (lazy flick)
     *                         and 1 (intense flick). The closer the value is to 1, the
     *                         faster the flick upwards will occur.
     */
    func flickDown(intensity: CGFloat) {
        UIView.animate(withDuration: Double(EditorPane.ANIMATION_TIME /
                                            intensity.constrainTo(0.5, 1)),
                       animations: {
            let bottom = UIScreen.main.bounds.maxY - EditorPane.MIN_HEIGHT
            self.view.frame = CGRect(x: 0, y: bottom,
                                     width: self.view.frame.width,
                                     height: self.view.frame.height)
            self.handleElementOpacities()
        })

        self.isExpanded = false
    }


    /**
     * Handles the ability to swipe the UI up and down on the iPhone. This functionality
     * is not available on the iPad, where the editor pane floats instead of being
     * swiped up from the bottom.
     *
     * - parameter gesture: `(UIPanGestureRecognizer)` the pan gesture that was recognized
     *                      by the system.
     */
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        /**
         * First, let's gather some information about the move itself.
         */
        let initialPos = self.view.frame.minY
        let move = gesture.translation(in: self.view)

        let targetY = initialPos + move.y
        let screenHeight = UIScreen.main.bounds.maxY
        let minY = screenHeight - maxHeight
        let maxY = screenHeight - EditorPane.MIN_HEIGHT


        /* if (tappedSomethingImportant(point: gesture.location(in: self.view))) {
            return;
        } */

        /**
         * If the pan gesture is over, try to see if the flick was strong enough to
         * justify flicking the editor pane into a given position.
         */
        if gesture.state == .ended {
            if targetY < minY {
                flickUp(doRubberband: false, intensity: 1)
                return
            }

            guard let lastMove = self.flick?.dir else {
                return
            }

            let intensity = abs(lastMove.y) / 30

            /**
             * If the flick was relatively low-intensity, just animate the editor pane to
             * whichever position is closer to the current scroll position regardless of
             * flick direction.
             */
            if intensity < 0.2 {
                let unfurlance = self.unfurlance()
                if unfurlance > 0.5 {
                    flickUp(doRubberband: lastMove.y < 0, intensity: 0.5)
                } else {
                    flickDown(intensity: 0.5)
                }

                return
            }

            /**
             * If it's a higher-intensity flick, consider the direction of the flick and
             * animate in that direction.
             */
            if lastMove.y < 0 {
                flickUp(doRubberband: initialPos < minY, intensity: intensity)
            } else {
                flickDown(intensity: intensity)
            }

            self.flick = nil
            return
        } // if gesture.state == .ended

        /**
         * Otherwise, handle normal scrolling. First up -- hitting the upper boundary of
         * how far the user is allowed to scroll.
         */
        if move.y < 0 && targetY < minY {
            let overscroll = minY - targetY
            let friction = (1.0 - (overscroll / EditorPane.FRICTION_DISTANCE))
                           .constrainTo(0, 1)

            self.view.frame = CGRect(x: 0,
                                     y: initialPos + (friction * move.y),
                                     width: self.view.frame.width,
                                     height: self.view.frame.height)

            handleElementOpacities()
        }

        /**
         * If the user tries to scroll the view past the bottom, don't do anything -- the
         * effect is that no scrolling occurs.
         */
        else if move.y > 0 && targetY > maxY {

        }

        /**
         * For any other scrolling within the allowed area, handle it normally.
         */
        else {
            self.view.frame = CGRect(x: 0,
                                     y: initialPos + move.y,
                                     width: self.view.frame.width,
                                     height: self.view.frame.height)

            handleElementOpacities()
        }

        /**
         * Finally, set the `flick` value in preparation for the end of the pan gesture.
         */
        let time = mach_absolute_time()
        if let oldFlick = self.flick {
            let deg = oldFlick.dir.y
            let dir = move.y.signum()

            /**
             * `dir != -deg.signum()` ensures that there hasn't been a sudden change of
             * direction that would cause the editor pane to flick the wrong way when the
             * user lets go. Note that, because `move.y` may sometimes be 0 right at the
             * end of a gesture, we need to use `dir != -deg.signum()` instead of
             * `dir == deg.signum()` (as 0.signum() = 0). That way, if the user's finger
             * drags a little on the screen right before letting go, the flick won't be
             * canceled entirely.
             *
             * `time - oldFlick.time < nanos(ms: 150)` makes sure that the
             * flick data is relatively recent (past 150 ms), so that an intense mid-pan
             * "flick" (i.e. high-speed scrolling) is not incorrectly interpreted as the
             * flick that occurred right at the end of the pan gesture.
             */
            if (dir != -deg.signum()) && (time - oldFlick.time < nanos(ms: 150)) {
                /**
                 * `determiner` is either the `min` or `max` function, depending on which
                 * direction the flicking is occurring in. If the user's flicking
                 * downwards (i.e., `move.y > 0`), the stored flick value should be the
                 * more *positive* of the two (i.e., `max(a, b)`). If the user's flicking
                 * upwards (i.e., `move.y < 0`), the stored flick value should be the more
                 * *negative* of the two (i.e., `min(a, b)`).
                 *
                 * The new time to be stored is simply the time at which the new flick
                 * value was measured.
                 */
                let determiner: (CGFloat, CGFloat) -> CGFloat = (dir == -1) ? min : max
                let newY = determiner(oldFlick.dir.y, move.y)
                let newTime = (newY == move.y) ? time : oldFlick.time

                self.flick = (dir: CGPoint(x: move.x,  y: newY), time: newTime)
            }

            /**
             * If the current pan gesture is in the opposite direction of what was stored,
             * or if it's been too long since that
             */
            else {
                self.flick = (dir: move, time: time)
            }
        } else {
            self.flick = (dir: move, time: mach_absolute_time())
        }

        gesture.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
    }


    /**
     * Handles the tapping of the expander / collapser button.
     *
     * - parameter tap: `(UITapGestureRecognizer)` the tap gesture that was recognized by
     *                  the system.
     */
    @objc func handleTap(tap: UITapGestureRecognizer) {
        /**
         * Since `self.expanderFrame` is `nil` on an iPad (see
         * `createHeader(label:accessibility:)`), this `guard` statement basically
         * ensures that this collapser/expander code doesn't execute on iPads.
         */
        guard let target = self.expanderFrame else {
            return
        }

        if tap.state == .ended {
            let pos = tap.location(in: self.view)

            if target.contains(pos) {
                if self.isExpanded {
                    self.flickDown(intensity: 1)
                } else {
                    self.flickUp(doRubberband: false, intensity: 1)
                }
            }
        } // if tap.state == .ended
    }


    private func tappedSomethingImportant(point: CGPoint) -> Bool {
        for (name, elem) in self.uiElements {
            if name == .heading || name == .explanation {
                continue
            }

            if elem.frame.contains(point) {
                return true
            }
        }

        return false
    }

}

public enum EditorPaneElement: Hashable {
    case heading

    case blockPicker
    case colorPicker

    case explanation
    case cloneButton
}


/**
 * Represents the different types of actions that may be performed by the editor.
 *
 * - author:  Sahir Shahryar
 * - since:   Monday, July 9, 2018
 * - version: 1.0.0
 */
public enum EditorMode: String {
    case addBlock
    case removeBlock
    case editBlock
}

/**
 * Represents the editor pane's `UIView`. Mostly used for linking with the EditorPaneView
 * XIB file.
 *
 * - author:  Sahir Shahryar
 * - since:   Tueday, July 3, 2018
 * - version: 1.0.0
 */
public class EditorPaneView: UIView {}
