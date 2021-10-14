//
//  TextBoxInputView.swift
//  FormTestApp
//
//  Created by Kevin Hu on 9/5/21.
//

import UIKit

class TextBoxInputView: LabeledInputView, InputView {

    // MARK: InputView Fields

    var id: String
    var value: Any {
        if textView.textColor == placeholderColor { return "" }
        return textView.text ?? ""
    }

    // MARK: UI Elements

    private var textView: UITextView!

    private var placeholder: String
    private var placeholderColor: UIColor = Color.InputView.placeholder
    private var textColor: UIColor = Color.blackText

    init(id: String, label: String, placeholder: String?) {
        self.id = id
        self.placeholder = placeholder ?? ""
        super.init(label: label)

        textView = UITextView()
        textView.delegate = self
        textView.text = placeholder
        textView.textColor = placeholderColor
        textView.font = Font.regular(12)
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1.5
        textView.layer.borderColor = Color.InputView.unfocused.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.heightAnchor.constraint(equalToConstant: 250).isActive = true

        stackView.alignment = .top
        stackView.addArrangedSubview(textView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension TextBoxInputView: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        // Change border color on focus
        textView.animateBorderColor(toColor: Color.InputView.focused, duration: 0.1)
        if textView.textColor == placeholderColor {
            textView.text = nil
            textView.textColor = textColor
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // Reset border color when ending focus
        textView.animateBorderColor(toColor: Color.InputView.unfocused, duration: 0.1)
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = placeholderColor
        }
    }

}
