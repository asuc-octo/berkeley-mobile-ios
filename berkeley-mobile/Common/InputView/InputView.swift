//
//  InputView.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 5/5/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

/** A view that gathers user input. */
protocol InputView: UIView {

    /// The user's currently-inputted value.
    var value: Any { get }

    /// A unique identifier for this field.
    var id: String { get }
}

/** A selection choice in an input field. This is a tuple of (identifier, display string) for the option. */
typealias InputOption = (id: String, display: String)

enum InputType {

    /// A single-line text input field.
    case textField(placeholder: String?)

    /// A multi-line text input field.
    case textBox(placeholder: String?)

    /// Select an integer in the range [`min`, `max`].
    case number(min: Int, max: Int)

    /// Select on a range between two options.
    case slider(notches: Int, leftLabel: String, rightLabel: String)

    /// Single-selection from a list of strings.
    case singleSelection(selections: [InputOption])

    /// Dropdown single-selection from a list of strings.
    case dropdownSingleSelection(selections: [InputOption])

    /// Multi-selection from a set of tags.
    case tagMultiSelection(selections: [InputTagType])

    /** Returns the view corresponding to the input type. */
    public func inputView(id: String, label: String) -> InputView {
        switch self {
        case .textField(let placeholder):
            return TextFieldInputView(id: id, label: label, placeholder: placeholder)
        case .textBox(let placeholder):
            return TextBoxInputView(id: id, label: label, placeholder: placeholder)
        case .number(let min, let max):
            return NumberInputView(id: id, label: label, min: min, max: max)
        case .slider(let notches, let leftLabel, let rightlabel):
            return SliderInputView(id: id, notches: notches, leftLabel: leftLabel, rightLabel: rightlabel)
        default:
            // TODO: Placeholder
            return TextFieldInputView(id: id, label: label, placeholder: "TODO: Placeholder")
        }
    }

}
