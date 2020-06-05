//
//  SearchDrawerViewDelegate.swift
//  bm-persona
//
//  Created by Shawn Huang on 4/28/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit

protocol SearchDrawerViewDelegate: DrawerViewDelegate {
    var mainContainer: MainContainerViewController? { get set }
}

extension SearchDrawerViewDelegate where Self: UIViewController {
    
    func presentDetail(type: AnyClass, item: SearchItem, containingVC: UIViewController, position: DrawerState) {
        let containingView = containingVC.view!
        if type == DiningHall.self {
            drawerViewController = DiningDetailViewController()
            (drawerViewController as! DiningDetailViewController).diningHall = (item as! DiningHall)
        } else if type == Library.self {
            drawerViewController = LibraryDetailViewController()
            (drawerViewController as! LibraryDetailViewController).library = (item as! Library)
        } else {
            return
        }
        containingVC.add(child: drawerViewController!)
        drawerViewController!.delegate = self
        drawerViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        drawerViewController!.view.heightAnchor.constraint(equalTo: containingView.heightAnchor).isActive = true
        drawerViewController!.view.widthAnchor.constraint(equalTo: containingView.widthAnchor).isActive = true
        drawerViewController!.view.centerXAnchor.constraint(equalTo: containingView.centerXAnchor).isActive = true
        // use cutoff position on detail view to determine "middle" state
        if let cutoff = (drawerViewController as! SearchDrawerViewController).middleCutoffPosition {
            drawerStatePositions[.middle] = containingView.frame.maxY + containingView.frame.maxY / 2 - cutoff
        } else {
            // default to showing 30% of the view if no cutoff set
            drawerStatePositions[.middle] = containingView.frame.midY + containingView.frame.maxY * 0.7
        }
        drawerStatePositions[.hidden] = containingView.frame.maxY + containingView.frame.maxY / 2
        drawerStatePositions[.full] = containingView.safeAreaInsets.top + (containingView.frame.maxY / 2)
        drawerViewController!.view.centerYAnchor.constraint(equalTo: containingView.centerYAnchor, constant: 2 * containingView.frame.maxY).isActive = true
        containingVC.view.layoutIfNeeded()
        self.initialDrawerCenter = self.drawerViewController!.view.center
        self.mainContainer?.coverTop(newTop: self, newState: position)
    }
    
    func computeDrawerPosition(from yPosition: CGFloat, with yVelocity: CGFloat) -> DrawerState {
        computePosition(from: yPosition, with: yVelocity, bottom: .hidden, middle: .middle, top: .full)
    }
    
}
