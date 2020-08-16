//
//  CalendarViewController.swift
//  bm-persona
//
//  Created by Oscar Bjorkman on 2/2/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import CoreLocation

fileprivate let kCardPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
fileprivate let kViewMargin: CGFloat = 16

class LibraryDetailViewController: SearchDrawerViewController {
    var library : Library!
    var overviewCard: OverviewCardView!
    var openTimesCard: OpenTimesCardView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpScrollView()
        setUpOverviewCard()
        setUpOpenTimesCard()
        setUpBookButton()
        
        // in order to set the cutoff correctly
        view.layoutSubviews()
        scrollView.layoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        /* Set the bottom cutoff point for when the drawer appears
        The "middle" position for the view will show everything in the overview card
        When collapsible open time card is added, change this to show that card as well. */
        middleCutoffPosition = (openTimesCard?.frame.maxY ?? overviewCard.frame.maxY) + scrollContainer.frame.minY + scrollView.contentInset.top + 8
        updateScrollView()
    }
    
    func updateScrollView() {
        scrollView.contentSize.height = scrollContent.frame.height
    }
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return scrollView
    }()
    var scrollContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var scrollContent: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var bookButton: UIButton = {
        let button = UIButton()
        button.layoutMargins = kCardPadding
        button.backgroundColor =  Color.eventAcademic
        button.layer.cornerRadius = 10
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = .zero
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowPath = UIBezierPath(rect: button.layer.bounds.insetBy(dx: 4, dy: 4)).cgPath
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Book a Study Room >", for: .normal)
        button.titleLabel!.font = Font.semibold(14)
        button.titleLabel!.textColor = .white
        return button
    }()
}

extension LibraryDetailViewController {
    func setUpOverviewCard() {
        overviewCard = OverviewCardView(item: library, excludedElements: [.openTimes, .occupancy])
        scrollContent.addSubview(overviewCard)
        overviewCard.topAnchor.constraint(equalTo: scrollContent.topAnchor).isActive = true
        overviewCard.leftAnchor.constraint(equalTo: scrollContent.leftAnchor).isActive = true
        overviewCard.rightAnchor.constraint(equalTo: scrollContent.rightAnchor).isActive = true
        overviewCard.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func setUpOpenTimesCard() {
        guard library.weeklyHours != nil else { return }
        openTimesCard = OpenTimesCardView(item: library, animationView: scrollView, toggleAction: { open in
            if open, self.currState != .full {
                self.delegate.moveDrawer(to: .full, duration: 0.6)
            }
        }, toggleCompletionAction: { _ in
            self.updateScrollView()
        })
        let openTimesCard = self.openTimesCard!
        scrollContent.addSubview(openTimesCard)
        openTimesCard.topAnchor.constraint(equalTo: overviewCard.bottomAnchor, constant: kViewMargin).isActive = true
        openTimesCard.leftAnchor.constraint(equalTo: scrollContent.leftAnchor).isActive = true
        openTimesCard.rightAnchor.constraint(equalTo: scrollContent.rightAnchor).isActive = true
    }
    
    func setUpBookButton() {
        scrollContent.addSubview(bookButton)
        bookButton.topAnchor.constraint(equalTo: openTimesCard?.bottomAnchor ?? overviewCard.bottomAnchor, constant: kViewMargin).isActive = true
        bookButton.leftAnchor.constraint(equalTo: scrollContent.leftAnchor).isActive = true
        bookButton.rightAnchor.constraint(equalTo: scrollContent.rightAnchor).isActive = true
        bookButton.bottomAnchor.constraint(equalTo: scrollContent.bottomAnchor).isActive = true
        bookButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setUpScrollView() {
        view.addSubview(scrollContainer)
        scrollContainer.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: kViewMargin).isActive = true
        scrollContainer.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        scrollContainer.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true
        scrollContainer.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        
        scrollContainer.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: scrollContainer.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: scrollContainer.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: scrollContainer.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: scrollContainer.bottomAnchor).isActive = true
        
        scrollView.addSubview(scrollContent)
        scrollContent.widthAnchor.constraint(equalTo: scrollContainer.widthAnchor, constant: -1 * (scrollView.contentInset.left + scrollView.contentInset.right)).isActive = true
        scrollContent.centerXAnchor.constraint(equalTo: scrollContainer.centerXAnchor).isActive = true
    }
}
