//
//  EventTapGestureRecognizer.swift
//  berkeley-mobile
//
//  Created by Oscar Bjorkman on 9/25/20.
//  Copyright © 2020 ASUC OCTO. All rights reserved.
//

import Foundation
import UIKit

/**
 * Custom Gesture Recognizer for  when creating linkable UIImageViews for Events. Allows us to pass parameters to a selector.
 */
class EventTapGestureRecognizer: UITapGestureRecognizer {
    
    var eventUrl = URL(string: "")
    
}
