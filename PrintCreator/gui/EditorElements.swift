//
//  EditorElements.swift
//  PrintCreator
//
//  Created by Sahir Shahryar on 7/9/18.
//  Copyright © 2018 Sahir Shahryar. All rights reserved.
//

import Foundation
import UIKit

/**
 * Represents a generic scrollable mode selector, such as a color picker or a block
 * picker.
 *
 * - author:  Sahir Shahryar
 * - since:   Tuesday, July 10, 2018
 * - version: 1.0.0
 */
public class ModeSelector<T>: UIScrollView {

    /**
     * Represents the space (in pixels) above and below each button.
     */
    fileprivate var verticalMargins: CGFloat = 24


    /**
     * Represents the
     */
    fileprivate var sideMargins: CGFloat = 24


    /**
     *
     */
    fileprivate var horizontalSpacing: CGFloat = 16


    /**
     *
     */
    public var selection: T? = nil


    /**
     *
     */
    private var buttons = [ModeSelectorButton<T>]()


    /**
     *
     */
    private var internalView: UIView? = nil


    /**
     *
     */
    public var height: CGFloat {
        return (2 * verticalMargins) + buttonHeight()
    }


    /**
     *
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.establish()
    }


    /**
     *
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.establish()
    }


    /**
     *
     */
    private final func establish() {
        let height = self.height
        var width = sideMargins

        var i = 0
        while let nextElem = generateElement(n: i) {
            if nextElem.parent == nil {
                nextElem.parent = self
            }

            nextElem.setX(width)

            buttons.append(nextElem)
            width += horizontalSpacing + nextElem.frame.width
            i += 1
        }

        width -= horizontalSpacing
        width += sideMargins

        self.internalView = UIView(frame: CGRect(x: 0, y: 0,
                                                 width: width, height: height))

        buttons[0].changeButtonState(selected: true)

        for elem in buttons {
            internalView!.addSubview(elem)
        }

        self.addSubview(self.internalView!)
        self.showsHorizontalScrollIndicator = false
        self.contentSize = self.internalView!.frame.size
        self.frame = CGRect(x: 0, y: 0, width: EditorPane.WIDTH, height: height)
    }


    public final func setY(_ newY: CGFloat) {
        self.frame = CGRect(x: 0, y: newY,
                            width: self.frame.width, height: self.frame.height)
    }


    /**
     * This function is called whenever a button is pressed.
     *
     * - parameter button: `(ModeSelectorButton<T>)` the button that was pressed.
     */
    public func optionSelected(button: ModeSelectorButton<T>) {
        self.selection = button.value

        for option in buttons {
            option.changeButtonState(selected: option == button)
        }
    }


    /**
     * Returns the height of each option button in the chooser. The button height should
     * be constant across all of the buttons in the chooser.
     */
    public func buttonHeight() -> CGFloat {
        assert(false, "ModeSelector#buttonHeight() was not overridden")
        return 0
    }


    /**
     * Gets the `n`th button in the chooser.
     *
     * - parameter n: `(Int)` the index of the button.
     *
     * - returns: `(ModeSelectorButton<T>)?` the button at the given index, or `nil` if
     *            the index is out of bounds. `nil` should be returned *immediately* after
     *            the last valid index, because the code used to assemble the picker
     *            loops until the value returned by this function is `nil`.
     */
    public func generateElement(n: Int) -> ModeSelectorButton<T>? {
        assert(false, "ModeSelector#getElementWidth() was not overridden")
        return nil
    }

}


/**
 * Represents a button in a generic picker.
 *
 * - author:  Sahir Shahryar
 * - since:   Tuesday, July 10, 2018
 * - version: 1.0.0
 */
public class ModeSelectorButton<T>: UIButton {

    /**
     *
     */
    fileprivate var parent: ModeSelector<T>? = nil


    /**
     *
     */
    fileprivate var value: T? = nil


    /**
     *
     */
    public init(value: T, parent: ModeSelector<T>) {
        super.init(frame: CGRect(x: 0, y: 0,
                                 width: parent.buttonHeight(),
                                 height: parent.buttonHeight()))
        self.value = value
        self.parent = parent
        self.establishTapTarget()
        self.initialize()
    }


    /**
     *
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.establishTapTarget()
        self.initialize()
    }


    /**
     *
     */
    private func establishTapTarget() {
        self.addTarget(self, action: #selector(optionSelected), for: .touchUpInside)
    }


    /**
     *
     */
    fileprivate func setX(_ x: CGFloat) {
        self.frame = CGRect(x: x,
                            y: (parent?.verticalMargins ?? self.frame.minY),
                            width: self.frame.width,
                            height: self.frame.height)
    }


    /**
     *
     */
    @objc func optionSelected() {
        self.parent?.optionSelected(button: self)
    }


    /**
     *
     */
    public func initialize() {
        assert(false, "ModeSelectorButton#initialize() was not overridden")
    }


    /**
     *
     */
    public func changeButtonState(selected: Bool) {
        assert(false, "ModeSelectorButton#changeButtonState() was not overridden")
    }

}


/**
 * Represents a button in the block picker.
 */
public class BlockChooser: ModeSelector<String> {

    /**
     *
     */
    public override func buttonHeight() -> CGFloat {
        return 36
    }


    /**
     *
     */
    public override func generateElement(n: Int) -> BlockChooserButton? {
        if n >= BlockTypes.ALL_BLOCK_TYPES.count {
            return nil
        }

        return BlockChooserButton(value: BlockTypes.ALL_BLOCK_TYPES[n], parent: self)
    }

}


/**
 *
 */
public class BlockChooserButton: ModeSelectorButton<String> {

    /**
     *
     */
    public override func initialize() {
        if let chooser = self.parent {
            let size = chooser.buttonHeight()
            self.frame = CGRect(x: 0, y: 0, width: size, height: size)
        }

        switch self.value! {
        case "cube":
            self.setImage(UIImage(named: "cube-icon"), for: .normal)
            self.setImage(UIImage(named: "cube-icon-selected"), for: .selected)
            self.imageView?.contentMode = .scaleAspectFit

        default:
            return
        }
    }


    /**
     *
     */
    public override func changeButtonState(selected: Bool) {
        self.isSelected = selected
    }

}


/**
 *
 */
public class ColorChooser: ModeSelector<Color> {

    /**
     *
     */
    public static let CHOOSABLE_COLORS: [Color] =
        [ .white, .black, .red, .green, .blue, .lightBlue, .purple, .turquoise, .peach ]


    /**
     *
     */
    public override func buttonHeight() -> CGFloat {
        return 32
    }


    /**
     *
     */
    public override func generateElement(n: Int) -> ColorChooserButton? {
        if n >= ColorChooser.CHOOSABLE_COLORS.count {
            return nil
        }

        return ColorChooserButton(value: ColorChooser.CHOOSABLE_COLORS[n],
                                   parent: self)
    }

}


/**
 *
 */
public class ColorChooserButton: ModeSelectorButton<Color> {

    public override func initialize() {
        self.layer.cornerRadius = CGFloat(Int(self.parent!.buttonHeight() / 2))

        let color = self.value!.toUI().cgColor
        self.layer.backgroundColor = color
    }

    public override func changeButtonState(selected: Bool) {
        if selected {
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
        } else {
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }

}


/**
 * Represents the clone button, which prompts the user to create a clone when it is
 * pressed.
 */
public class CloneButton: UIButton {}

