//
//  SelectClassView.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 1/30/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit

class SelectClassView: UIView, UITextFieldDelegate, EnableNextDelegate {
    let preferenceVC: CreatePreferenceViewController
    var textField: MaterialTextField!
    var classNames: [String] = []
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public init(preferenceVC: CreatePreferenceViewController) {
        self.preferenceVC = preferenceVC
        super.init(frame: .zero)
        setUpView()
        loadClasses()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpView() {
        self.textField = MaterialTextField(hint: "Search for a class", textColor: Color.darkGrayText, font: Font.regular(15), bgColor: Color.searchBarBackground, delegate: self)
        textField.cornerRadius = 15.0
        textField.setCornerBorder(color: Color.searchBarBackground, cornerRadius: 15.0, borderWidth: 0.0)
        textField.autocorrectionType = .no
        textField.returnKeyType = .search
        textField.enablesReturnKeyAutomatically = true
        textField.layer.masksToBounds = false
        textField.padding = CGSize(width: 10, height: 0)
        textField.addTarget(self, action: #selector(setNextEnabled), for: .editingDidEnd)
        
        textField.layer.shadowRadius = 5
        textField.layer.shadowOpacity = 0.25
        textField.layer.shadowOffset = .zero
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowPath = UIBezierPath(rect: layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
        
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        textField.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    func loadClasses() {
        guard self.classNames.count == 0,
              let url = URL(string: "https://berkeleytime.com/api/catalog/catalog_json/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            guard let data = data, let response = response,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  error == nil else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                let courses = json["courses"] as! Array<Dictionary<String, AnyObject>>
                for course in courses {
                    guard let courseNumber = course["course_number"] as? String,
                          let abbreviation = course["abbreviation"] as? String else { continue }
                    self.classNames.append(abbreviation + " " + courseNumber)
                }
            } catch {
                print("error fetching courses")
            }
        })
        task.resume()
    }
    
    @objc func setNextEnabled() {
        if textField.text == nil || textField.text == "" {
            isNextEnabled = false
        } else {
            isNextEnabled = true
            preferenceVC.preference.className = textField.text
        }
    }
    var isNextEnabled: Bool = false {
        didSet {
            preferenceVC.setNextEnabled()
        }
    }
}
