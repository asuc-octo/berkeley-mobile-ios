//
//  TwoColumnInputView.swift
//  FormTestApp
//
//  Created by Kevin Hu on 9/5/21.
//

import UIKit

class LabeledInputView: UIView {

    // MARK: UI Elements

    public var stackView: UIStackView!
    public var fieldLabel: UILabel!

    init(label: String, leftColumnWidth: CGFloat = 85) {
        super.init(frame: .zero)

        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 15
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor).isActive = true

        fieldLabel = UILabel()
        fieldLabel.text = label
        fieldLabel.font = Font.regular(13)
        fieldLabel.numberOfLines = 0
        fieldLabel.widthAnchor.constraint(equalToConstant: leftColumnWidth).isActive = true
        stackView.addArrangedSubview(fieldLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
