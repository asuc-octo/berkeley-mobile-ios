//
//  NumberInputView.swift
//  FormTestApp
//
//  Created by Kevin Hu on 9/26/21.
//

import UIKit

private let kMaxButtonsPerRow: Int = 5

class NumberInputView: LabeledInputView, InputView {

    // MARK: InputView Fields

    var id: String
    var value: Any {
        return buttonSelected?.number as Any
    }

    // MARK: Private Fields

    private var buttonSelected: GroupNumberButton?

    init(id: String, label: String, min: Int, max: Int) {
        self.id = id
        super.init(label: label)

        let stackY = UIStackView()
        stackY.axis = .vertical
        stackY.distribution = .equalSpacing

        let rows: Int = Int(ceil(Double(max - min + 1) / Double(kMaxButtonsPerRow)))
        var currentInt: Int = min
        for _ in 1...rows {
            let stackX = UIStackView()
            stackX.axis = .horizontal
            stackX.distribution = .equalSpacing
            stackX.translatesAutoresizingMaskIntoConstraints = false
            let items = kMaxButtonsPerRow < max - currentInt + 1 ? kMaxButtonsPerRow : max - currentInt + 1
            for _ in 1...items {
                let btn = buttonGenerator(num: currentInt)
                stackX.addArrangedSubview(btn)
                currentInt += 1
            }
            stackY.addArrangedSubview(stackX)
        }

        stackView.alignment = .top
        stackView.addArrangedSubview(stackY)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func buttonGenerator(num: Int) -> UIButton {
        let btn = GroupNumberButton(number: num)
        btn.setTitleColor(Color.blackText, for: .normal)
        btn.titleLabel?.font = Font.regular(14)
        btn.contentMode = .scaleAspectFit
        btn.translatesAutoresizingMaskIntoConstraints = false

        let radius: CGFloat = 15
        btn.widthAnchor.constraint(equalToConstant: 2 * radius).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 2 * radius).isActive = true
        btn.layer.cornerRadius = radius
        btn.addTarget(self, action: #selector(toggleButton(sender:)), for: .touchUpInside)

        return btn
    }

    @objc private func toggleButton(sender: GroupNumberButton) {
        if !sender.isSelected {
            sender.backgroundColor = Color.InputView.selected
            sender.setTitleColor(.white, for: .normal)
            sender.isSelected.toggle()
            sender.border?.isHidden = true

            if let buttonSelected = self.buttonSelected {
                buttonSelected.border?.isHidden = false
                buttonSelected.backgroundColor = nil
                buttonSelected.setTitleColor(Color.blackText, for: .normal)
                buttonSelected.isSelected.toggle()
            }
            self.buttonSelected = sender
        }
    }

}

private class GroupNumberButton: UIButton {

    let number: Int
    var border: CAShapeLayer?

    init(number: Int) {
        self.number = number
        super.init(frame: .zero)
        self.setTitle(String(number), for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if border == nil {
            let bounds = self.bounds
            border = CAShapeLayer.init()
            guard let border = border else { return }
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: self.layer.cornerRadius)
            border.path = path.cgPath
            border.strokeColor = Color.InputView.focused.cgColor
            border.lineDashPattern = [2, 2]
            border.fillColor = nil
            self.layer.addSublayer(border)
        }
    }
}
