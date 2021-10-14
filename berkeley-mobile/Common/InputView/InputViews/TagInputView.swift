//
//  TagInputView.swift
//  FormTestApp
//
//  Created by Kevin Hu on 10/6/21.
//

import UIKit

typealias InputTagType = (option: InputOption, color: UIColor)

class TagInputView: LabeledInputView, InputView {

    // MARK: InputView Fields

    var id: String
    var value: Any {
        return selectedTags.map { $0.option.id }
    }

    // MARK: UI Elements

    private var rhsView: UIView!
    private var cardView: CardView!
    private var textField: UITextField!
    private var resultsView: UITableView!
    private var collectionView: UICollectionView!

    private var selectedTags: [InputTagType] = []

    init(id: String, label: String, selections: [InputTagType]) {
        self.id = id
        super.init(label: label)

        rhsView = UIView()

        cardView = CardView()
        cardView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        rhsView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.topAnchor.constraint(equalTo: rhsView.topAnchor).isActive = true
        cardView.leftAnchor.constraint(equalTo: rhsView.leftAnchor).isActive = true
        cardView.rightAnchor.constraint(equalTo: rhsView.rightAnchor).isActive = true

        textField = UITextField()
        textField.delegate = self
        textField.textColor = Color.blackText
        textField.font = Font.regular(12)
        let padding = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10, height: 1.0))
        let rightIconView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 23, height: 11))
        let searchIcon = UIImageView(image: UIImage(named: "Search")?
                                        .resized(size: CGSize(width: 11, height: 11)))
        searchIcon.frame = CGRect(x: 0.0, y: 0.0, width: 11, height: 11)
        searchIcon.contentMode = .center
        rightIconView.addSubview(searchIcon)
        textField.leftView = padding
        textField.rightView = rightIconView
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        cardView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 26).isActive = true
        textField.topAnchor.constraint(equalTo: cardView.layoutMarginsGuide.topAnchor).isActive = true
        textField.leftAnchor.constraint(equalTo: cardView.layoutMarginsGuide.leftAnchor).isActive = true
        textField.rightAnchor.constraint(equalTo: cardView.layoutMarginsGuide.rightAnchor).isActive = true

        resultsView = UITableView()
        cardView.addSubview(resultsView)
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        resultsView.topAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true
        resultsView.leftAnchor.constraint(equalTo: cardView.layoutMarginsGuide.leftAnchor).isActive = true
        resultsView.rightAnchor.constraint(equalTo: cardView.layoutMarginsGuide.rightAnchor).isActive = true
        resultsView.bottomAnchor.constraint(equalTo: cardView.layoutMarginsGuide.bottomAnchor).isActive = true

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        rhsView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 10).isActive = true
        collectionView.leftAnchor.constraint(equalTo: rhsView.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rhsView.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: rhsView.bottomAnchor).isActive = true

        stackView.addArrangedSubview(rhsView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension TagInputView: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
    }

}
