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
