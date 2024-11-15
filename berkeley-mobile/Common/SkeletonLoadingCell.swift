//
//  SkeletonLoadingCell.swift
//  berkeley-mobile
//
//  Created by Justin Wong on 7/5/24.
//  Copyright © 2024 ASUC OCTO. All rights reserved.
//

import UIKit

//https://github.com/jrasmusson/swift-arcade/blob/master/Animation/Shimmer/README.md
// MARK: - SkeletonLoadable
protocol SkeletonLoadable {}

extension SkeletonLoadable {
    
    func makeAnimationGroup(previousGroup: CAAnimationGroup? = nil) -> CAAnimationGroup {
        let animDuration: CFTimeInterval = 1.5
        let anim1 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
        anim1.fromValue = BMColor.gradientLightGrey.cgColor
        anim1.toValue = BMColor.gradientDarkGrey.cgColor
        anim1.duration = animDuration
        anim1.beginTime = 0.0

        let anim2 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
        anim2.fromValue = BMColor.gradientDarkGrey.cgColor
        anim2.toValue = BMColor.gradientLightGrey.cgColor
        anim2.duration = animDuration
        anim2.beginTime = anim1.beginTime + anim1.duration

        let group = CAAnimationGroup()
        group.animations = [anim1, anim2]
        group.repeatCount = .greatestFiniteMagnitude // infinite
        group.duration = anim2.beginTime + anim2.duration
        group.isRemovedOnCompletion = false

        if let previousGroup = previousGroup {
            // Offset groups by 0.33 seconds for effect
            group.beginTime = previousGroup.beginTime + 0.33
        }

        return group
    }
}

// MARK: - SkeletonLoadingCell
class SkeletonLoadingCell: UITableViewCell, SkeletonLoadable {
    
    static let kCellIdentifier = "SkeletonLoadingCell"

    let shimmerView = UIView()
    let viewLayer = CAGradientLayer()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        viewLayer.frame = shimmerView.bounds
        viewLayer.cornerRadius = 20
    }
}

extension SkeletonLoadingCell {

    func setup() {
        shimmerView.translatesAutoresizingMaskIntoConstraints = false
        
        viewLayer.startPoint = CGPoint(x: 0, y: 0.5)
        viewLayer.endPoint = CGPoint(x: 1, y: 0.5)
        shimmerView.layer.addSublayer(viewLayer)

        let titleGroup = makeAnimationGroup()
        titleGroup.beginTime = 0.0
        viewLayer.add(titleGroup, forKey: "backgroundColor")
        
        backgroundView = .none
        backgroundColor = BMColor.cardBackground
        
        isUserInteractionEnabled = false
    }
    
    func layout() {
        addSubview(shimmerView)
        
        let padding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            shimmerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            shimmerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            shimmerView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            shimmerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        ])
    }
}
