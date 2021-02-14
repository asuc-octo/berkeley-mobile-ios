//
//  MapMarkerDetailView.swift
//  bm-persona
//
//  Created by Kevin Hu on 3/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16
fileprivate let kButtonSize: CGFloat = 24

// MARK: - MapMarkerDetailViewDelegate

protocol MapMarkerDetailViewDelegate {
    func didCloseMarkerDetailView(_ sender: MapMarkerDetailView);
}

// MARK: - MapMarkerDetailView

/** The view that is shown when a  `MapMarker` is selected. */
class MapMarkerDetailView: UIView {
    
    open var marker: MapMarker? {
        didSet {
            if let marker = marker {
                setupView(marker)
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 1.0
                }) { completed in self.isHidden = !completed }
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0.0
                }) { completed in  self.isHidden = completed }
            }
        }
    }
    
    open var delegate: MapMarkerDetailViewDelegate?
    
    private var closeButton: UIButton!
    private var backgroundView: CardView!
    private var containerView: UIView!
    private var typeColorView: UIView!
    private var contentView: UIView!
    
    private var verticalStack: UIStackView!
    private var nameLabel: UILabel!
    private var notesLabel: UILabel!
    private var detailStack: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView = CardView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        backgroundView.setConstraintsToView(top: self, bottom: self, left: self, right: self)
        
        containerView = UIView()
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(containerView)
        containerView.setConstraintsToView(top: backgroundView, bottom: backgroundView, left: backgroundView, right: backgroundView)
        
        typeColorView = UIView()
        typeColorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(typeColorView)
        typeColorView.setConstraintsToView(top: containerView, bottom: containerView, left: containerView)
        typeColorView.setWidthConstraint(10)
        
        contentView = UIView()
        contentView.layoutMargins = kCardPadding
        contentView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(contentView)
        contentView.setConstraintsToView(top: containerView, bottom: containerView, right: containerView)
        contentView.leftAnchor.constraint(equalTo: typeColorView.rightAnchor).isActive = true
        
        let iconSize: CGFloat = 16
        let offset = (kButtonSize - iconSize) / 2
        let closeImage = UIImage(named: "Clear")?.resized(size: CGSize(width: iconSize, height: iconSize))
        closeButton = UIButton(type: .system)
        closeButton.tintColor = Color.primaryText
        closeButton.setImage(closeImage, for: .normal)
        closeButton.imageView?.contentMode = .center
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        // The button is larger for user interaction, so we offset the constraints so the image is still visually in the correct place.
        closeButton.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: -offset).isActive = true
        closeButton.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor, constant: offset).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: kButtonSize).isActive = true
        
        //gesture dissapear
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(closeView))
        swipeDown.direction = .down
        self.addGestureRecognizer(swipeDown)
        
        nameLabel = UILabel()
        contentView.addSubview(nameLabel)
        nameLabel.numberOfLines = 0
        nameLabel.font = Font.bold(20)
        nameLabel.textColor = Color.primaryText
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: -offset).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: closeButton.leftAnchor).isActive = true
        
        verticalStack = UIStackView(axis: .vertical, distribution: .fill, spacing: kViewMargin)
        contentView.addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: kViewMargin).isActive = true
        verticalStack.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor).isActive = true
        verticalStack.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor).isActive = true

        notesLabel = UILabel()
        notesLabel.numberOfLines = 0
        notesLabel.font = Font.light(10)
        notesLabel.textColor = Color.primaryText
        
        detailStack = UIStackView(axis: .horizontal, distribution: .fill, spacing: kViewMargin)
        detailStack.alignment = .center
    
        verticalStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = backgroundView.layer.cornerRadius
    }
    
    // TODO: A bit expensive to remake views + constraints. Fix by keeping references to views.
    private func setupView(_ marker: MapMarker) {
        verticalStack.removeAllArrangedSubviews()
        nameLabel.text = marker.title
        typeColorView.backgroundColor = marker.type.color()
        notesLabel.text = marker.subtitle
        
        detailStack.removeAllArrangedSubviews()
        // Show average meal price only for cafe markers
        let details: [MapMarkerDetail] = marker.type == .cafe ?
            [.distance, .openNow, .location, .price] :
            [.distance, .openNow, .location]
        var containsFlexibleView = false
        for property: MapMarkerDetail in details {
            if let view = property.view(marker) {
                detailStack.addArrangedSubview(view)
                containsFlexibleView = containsFlexibleView || !property.inflexible
            }
        }
        // Add empty 'padding' view to prevent stretching of 'inflexible' views.
        if !containsFlexibleView {
            detailStack.addArrangedSubview(UIView())
        }
                
        if (notesLabel.text?.count ?? 0) > 0 {
            verticalStack.addArrangedSubview(notesLabel)
        }
        if !detailStack.arrangedSubviews.isEmpty {
            verticalStack.addArrangedSubview(detailStack)
        }
    }
    
    @objc func closeView() {
        marker = nil
        delegate?.didCloseMarkerDetailView(self)
    }

}

// MARK: - MapMarkerDetail

/** Describes types of subviews for `MapMarkerDetailView`. */
enum MapMarkerDetail {
    
    case location
    case openNow
    case distance
    case price

    /** Boolean that is `true` if the view for this detail should not be stretched horizontally. */
    var inflexible: Bool {
        return self != .location
    }
    
    /** Helper that returns a view next to an icon */
    func viewWithIcon(_ icon: UIImage?, view: UIView) -> UIView {
        let container = UIView()
        
        let imageView = UIImageView(image: icon?.resized(size: CGSize(width: 17, height: 17)))
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        container.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setConstraintsToView(top: container, bottom: container, left: container)
        
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
        view.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        
        return container
    }
    
    /**
       The subviews for a given type of detail.
       - Parameter marker: The marker with the information to display
       - Returns: The subview, or `nil` if the information is not found in `marker`.
     */
    func view(_ marker: MapMarker) -> UIView? {
        switch self {
        case .openNow:
            guard let isOpen = marker.isOpen else { return nil }
            let icon = UIImage(named: "Clock")
            let tag = isOpen ? TagView.open : TagView.closed
            return viewWithIcon(icon, view: tag)
        case .location:
            guard let description = marker.address else { return nil }
            let icon = UIImage(named: "Placemark")
            let label = UILabel()
            label.numberOfLines = 0
            label.font = Font.light(12)
            label.textColor = Color.primaryText
            label.text = description
            return viewWithIcon(icon, view: label)
        case .price:
            guard let price = marker.mealPrice else { return nil }
            let icon = UIImage(named: "Dining")
            let label = UILabel()
            label.numberOfLines = 1
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.font = Font.light(12)
            label.textColor = Color.primaryText
            label.text = price
            return viewWithIcon(icon, view: label)
        default:
            // TODO: Get distance to marker
            return nil
        }
    }
    
}
