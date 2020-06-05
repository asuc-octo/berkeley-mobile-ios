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
        drawerViewController!.view.frame = containingView.frame
        drawerViewController!.view.center.y = containingView.frame.maxY * 1.5
        drawerViewController!.view.translatesAutoresizingMaskIntoConstraints = true
        drawerViewController!.view.layoutIfNeeded()
        
        if let cutoff = (drawerViewController as! SearchDrawerViewController).middleCutoffPosition {
            drawerStatePositions[.middle] = containingView.frame.maxY + containingView.frame.maxY / 2 - cutoff
        } else {
            // default to showing 30% of the view if no cutoff set
            drawerStatePositions[.middle] = containingView.frame.midY + containingView.frame.maxY * 0.7
        }
        drawerStatePositions[.hidden] = containingView.frame.maxY + containingView.frame.maxY / 2
        drawerStatePositions[.full] = containingView.safeAreaInsets.top + (containingView.frame.maxY / 2)
        containingVC.view.layoutIfNeeded()
        self.initialDrawerCenter = self.drawerViewController!.view.center
        self.mainContainer?.coverTop(newTop: self, newState: position)
    }
    
    func computeDrawerPosition(from yPosition: CGFloat, with yVelocity: CGFloat) -> DrawerState {
        computePosition(from: yPosition, with: yVelocity, bottom: .hidden, middle: .middle, top: .full)
    }
    
}
