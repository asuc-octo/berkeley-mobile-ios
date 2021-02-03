//
//  SelectClassView.swift
//  berkeley-mobile
//
//  Created by Eashan Mathur on 1/30/21.
//  Copyright © 2021 ASUC OCTO. All rights reserved.
//

import UIKit
import SearchTextField

class SelectClassView: UIView, UITextFieldDelegate, EnableNextDelegate {
    weak var preferenceVC: CreatePreferenceViewController?
    var textField: SearchTextField!
    var classNames: [String] = []
    
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
        self.textField = SearchTextField()
        textField.placeholder = "Search for a class"
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 10
        textField.theme.font = Font.light(12)
        textField.addTarget(self, action: #selector(setNextEnabled), for: .editingDidEnd)
        
        textField.layer.shadowRadius = 3
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
            DispatchQueue.main.async {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    let courses = json["courses"] as! Array<Dictionary<String, AnyObject>>
                    for course in courses {
                        guard let courseNumber = course["course_number"] as? String,
                              let abbreviation = course["abbreviation"] as? String else { continue }
                        self.classNames.append(abbreviation + " " + courseNumber)
                    }
                    self.textField.filterStrings(self.classNames)
                } catch {
                    print("error fetching courses")
                }
            }
        })
        task.resume()
    }
    
    @objc func setNextEnabled() {
        if textField.text == nil || textField.text == "" {
            isNextEnabled = false
        } else {
            isNextEnabled = true
            guard let preferenceVC = self.preferenceVC else { return }
            preferenceVC.preference.className = textField.text
        }
    }
    var isNextEnabled: Bool = false {
        didSet {
            guard let preferenceVC = self.preferenceVC else { return }
            preferenceVC.setNextEnabled()
        }
    }
}
