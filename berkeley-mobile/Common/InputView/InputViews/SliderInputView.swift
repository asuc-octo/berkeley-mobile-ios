//
//  SliderInputView.swift
//  FormTestApp
//
//  Created by Kevin Hu on 9/26/21.
//

import UIKit

class SliderInputView: UIView, InputView {

    // MARK: InputView Fields

    var id: String
    var value: Any {
        return buttonSelected?.id as Any
    }

    // MARK: UI Elements

    private var stackView: UIStackView!
    private var lineLayer: CAShapeLayer?
    private var buttonSelected: NotchButton?

    init(id: String, notches: Int, leftLabel: String, rightLabel: String) {
        self.id = id
        super.init(frame: .zero)

        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor).isActive = true

        for i in 0..<notches {
            let btn = buttonGenerator(id: i)
            stackView.addArrangedSubview(btn)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let line = lineLayer ?? CAShapeLayer()
        let lineBounds = CGRect(x: 0, y: (bounds.height - 3.5) / 2, width: bounds.width, height: 3.5)
        let path = UIBezierPath(roundedRect: lineBounds, cornerRadius: lineBounds.height / 2)
        line.path = path.cgPath
        line.fillColor = Color.InputView.radioBorder.cgColor
        line.opacity = 1.0
        layer.insertSublayer(line, at: 0)
        lineLayer = line
    }

    func buttonGenerator(id: Int) -> UIButton {
        let btn = NotchButton(id: id)
        btn.contentMode = .scaleAspectFit
        btn.translatesAutoresizingMaskIntoConstraints = false

        let radius: CGFloat = 10
        btn.widthAnchor.constraint(equalToConstant: 2 * radius).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 2 * radius).isActive = true
        btn.layer.cornerRadius = radius
        btn.layer.borderColor = Color.InputView.radioBorder.cgColor
        btn.layer.borderWidth = 3.5
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(toggleButton(sender:)), for: .touchUpInside)

        return btn
    }

    @objc private func toggleButton(sender: NotchButton) {
        if !sender.isSelected {
            sender.backgroundColor = Color.InputView.selected
            sender.layer.borderColor = Color.InputView.selected.cgColor
            sender.isSelected.toggle()

            if let buttonSelected = self.buttonSelected {
                buttonSelected.backgroundColor = .white
                buttonSelected.layer.borderColor = Color.InputView.radioBorder.cgColor
                buttonSelected.isSelected.toggle()
            }
            self.buttonSelected = sender
        }
    }

}

private class NotchButton: UIButton {

    let id: Int

    init(id: Int) {
        self.id = id
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
