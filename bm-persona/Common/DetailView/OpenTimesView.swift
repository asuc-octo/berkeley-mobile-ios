//
//  OpenTimesCardView.swift
//  bm-persona
//
//  Created by Shawn Huang on 7/4/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

fileprivate let kViewMargin: CGFloat = 16

class OpenTimesCardView: CollapsibleCardView {
    var item: HasOpenTimes!

    public init(item: HasOpenTimes, openedAction: (() -> Void)? = nil) {
        let cView = UIView()
        cView.backgroundColor = .red
        cView.translatesAutoresizingMaskIntoConstraints = false
        cView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        let oView = UIView()
        oView.backgroundColor = .blue
        oView.translatesAutoresizingMaskIntoConstraints = false
        oView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        super.init(collapsedView: cView, openedView: oView, leftIcon: clockIcon)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
//    func collapsedView() -> UIView {
//        if let isOpen = item.isOpen {
//            if isOpen {
//                openTag.text = "Open"
//                openTag.backgroundColor = Color.openTag
//            } else {
//                openTag.text = "Closed"
//                openTag.backgroundColor = Color.closedTag
//            }
//            openTag.widthAnchor.constraint(equalToConstant: 50).isActive = true
//        }
//    }
    
    private func leftRightView(leftView: UIView, rightView: UIView) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leftView)
        view.addSubview(rightView)
        
        leftView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        leftView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        rightView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        rightView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        rightView.leftAnchor.constraint(greaterThanOrEqualTo: leftView.rightAnchor, constant: kViewMargin).isActive = true
        
        return view
    }
    
    let clockIcon: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "Clock")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    let openTag: TagView = {
        let tag = TagView(origin: .zero, text: "", color: .clear)
        tag.translatesAutoresizingMaskIntoConstraints = false
        return tag
    }()
}
