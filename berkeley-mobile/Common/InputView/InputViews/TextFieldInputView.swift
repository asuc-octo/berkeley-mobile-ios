//
//  TextFieldInputView.swift
//  berkeley-mobile
//
//  Created by Kevin Hu on 5/5/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class TextFieldInputView: LabeledInputView, InputView {

    // MARK: InputView Fields

    var id: String
    var value: Any {
        return textField.text ?? ""
    }

    // MARK: UI Elements

    private var textField: UITextField!

    init(id: String, label: String, placeholder: String?) {
        self.id = id
        super.init(label: label)

        textField = UITextField()
        textField.delegate = self
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = Color.InputView.unfocused.cgColor
        textField.textColor = Color.blackText
        textField.font = Font.regular(12)
        textField.attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [
            NSAttributedString.Key.foregroundColor: Color.InputView.placeholder,
            NSAttributedString.Key.font: Font.regular(12)
        ])
        let padding = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 15, height: 1.0))
        textField.leftView = padding
        textField.rightView = padding
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.heightAnchor.constraint(equalToConstant: 36).isActive = true

        stackView.addArrangedSubview(textField)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextFieldInputView: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Change border color on focus
        textField.animateBorderColor(toColor: Color.InputView.focused, duration: 0.1)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // Reset border color when ending focus
        textField.animateBorderColor(toColor: Color.InputView.unfocused, duration: 0.1)
    }

}
