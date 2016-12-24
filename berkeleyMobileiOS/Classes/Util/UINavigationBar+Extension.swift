
import Foundation
import UIKit

fileprivate let kHairlineKey = "hidesShadow"

extension UINavigationBar
{
    /**
     * UINavigationBar by default has a 1px drop shadow,
     * which can only be hidden through KVO means.
     */
    open var hideHairline: Bool
    {
        set { self.setValue(newValue, forKey: kHairlineKey) }
        get { return self.value(forKey: kHairlineKey) as! Bool  }
    }
}
