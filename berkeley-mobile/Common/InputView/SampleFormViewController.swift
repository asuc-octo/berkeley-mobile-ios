//
//  FormViewController.swift
//  FormTestApp
//
//  Created by Kevin Hu on 9/5/21.
//

import UIKit

class SampleFormViewController: UIViewController {

    /// A stack view containing all the input views.
    private var stackView: UIStackView!

    /// The list of fields to be displayed in the form, in order.
    private var formFields: [(id: String, label: String, type: InputType)]! {
        didSet {
            //stackView.removeAllArrangedSubviews()
            for view in stackView.arrangedSubviews {
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            _ = formFields.map { stackView.addArrangedSubview($0.type.inputView(id: $0.id, label: $0.label)) }
        }
    }

    /// Returns the user's selected values for this form.
    public var formValues: [String: Any] {
        Dictionary(uniqueKeysWithValues: stackView.arrangedSubviews.compactMap { view in
            guard let inputView = view as? InputView else { return nil }
            return (inputView.id, inputView.value)
        })
    }

    @objc func submitForm() {
        print(formValues)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fill
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true

        // TODO: This is a placeholder for testing
        formFields = [
            (id: "pronouns", label: "Pronouns", type: .textField(placeholder: "he/him/his")),
            (id: "bio", label: "Bio", type: .textBox(placeholder: "A little bit about you!")),
            (id: "roommate_count", label: "Preferred # of roomates", type: .number(min: 1, max: 5)),
            (id: "personality", label: "", type: .slider(notches: 5, leftLabel: "Introverted", rightLabel: "Extroverted"))
        ]

        let button = UIButton()
        button.setTitle("Get Values", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.black
        button.addTarget(self, action: #selector(submitForm), for: .touchUpInside)
        stackView.addArrangedSubview(button)
    }
}

