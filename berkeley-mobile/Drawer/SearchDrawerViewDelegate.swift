//
//  SearchDrawerViewDelegate.swift
//  bm-persona
//
//  Created by Shawn Huang on 4/28/20.
//  Copyright © 2020 RJ Pimentel. All rights reserved.
//

import UIKit
import MapKit

// Drawer delegate that can present a detail view drawer onto the main container
protocol SearchDrawerViewDelegate: DrawerViewDelegate {
    // the outermost, containing view controller (to present the drawer onto)
    var mainContainer: MainContainerViewController? { get set }
    
    // the delegate for dropping a pin on the map
    var pinDelegate: SearchResultsViewDelegate? { get set }
}

extension SearchDrawerViewDelegate where Self: UIViewController {
    
    /* present a detail view drawer
     type is set to DiningHall, Library, etc. to determine what type of detail view is needed */
    func presentDetail(type: AnyClass, item: SearchItem, containingVC: UIViewController, position: DrawerState) {
        let containingView = containingVC.view!
        if type == DiningHall.self {
            drawerViewController = DiningDetailViewController()
            (drawerViewController as! DiningDetailViewController).diningHall = (item as! DiningLocation)
        } else if type == Library.self {
            drawerViewController = LibraryDetailViewController()
            (drawerViewController as! LibraryDetailViewController).library = (item as! Library)
        } else if type == Gym.self {
            drawerViewController = GymDetailViewController()
            (drawerViewController as! GymDetailViewController).gym = (item as! Gym)
        } else if type == Resource.self {
            drawerViewController = CampusResourceDetailViewController()
            (drawerViewController as! CampusResourceDetailViewController).resource = (item as! Resource)
        } else {
            return
        }
        containingVC.add(child: drawerViewController!)
        drawerViewController!.delegate = self
        // set the size of the new drawer to be equal to the size of the containing view
        drawerViewController!.view.frame = containingView.frame
        // drawer starts in the hidden position, will move up from there
        drawerViewController!.view.center.y = containingView.frame.maxY * 1.5
        // necessary to move the center of the drawer later on
        drawerViewController!.view.translatesAutoresizingMaskIntoConstraints = true
        // necessary to set the correct cutoff for the 'middle' position of the drawer
        drawerViewController!.view.layoutIfNeeded()
        drawerViewController!.viewDidLayoutSubviews()
        
        if let cutoff = (drawerViewController as! SearchDrawerViewController).middleCutoffPosition {
            // offset to indicate drawers are draggable
            let dragOffset: CGFloat = 30
            drawerStatePositions[.middle] = containingView.frame.maxY + containingView.frame.maxY / 2 - cutoff - dragOffset
        } else {
            // default to showing 30% of the view if no cutoff set
            drawerStatePositions[.middle] = containingView.frame.midY + containingView.frame.maxY * 0.7
        }
        drawerStatePositions[.hidden] = containingView.frame.maxY + containingView.frame.maxY / 2
        drawerStatePositions[.full] = containingView.safeAreaInsets.top + (containingView.frame.maxY / 2)
        containingVC.view.layoutIfNeeded()
        self.initialDrawerCenter = self.drawerViewController!.view.center
        // add the new drawer on top of all existing ones
        self.mainContainer?.coverTop(newTop: self, newState: position)
    }
    
    func dropPin(item: SearchItem?) {
        guard let item = item else { return }
        pinDelegate?.choosePlacemark(MapPlacemark(loc: CLLocation(latitude: item.location.0, longitude: item.location.1), name: item.name, locName: item.locationName, item: item))
    }
    
    // depending on a pan gesture, return which position to go to
    func computeDrawerPosition(from yPosition: CGFloat, with yVelocity: CGFloat) -> DrawerState {
        computePosition(from: yPosition, with: yVelocity, bottom: .hidden, middle: .middle, top: .full)
    }

    // A default implentation of the `DrawerViewDelegate` method that removes the drawer when swiped down completely.
    // This implementation can be overridden if needed.
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let state = handlePan(gesture: gesture)
        if state == .hidden {
            // get rid of the top detail drawer if user sends it to bottom of screen
            mainContainer?.dismissTop()
        }
    }
    
}
