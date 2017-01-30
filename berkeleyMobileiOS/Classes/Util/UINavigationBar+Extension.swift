
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
    
    /**
     * Make the navigationBar completely transparent by setting an empty image.
     */
    open func setTransparent(_ transparent: Bool)
    {
        if transparent
        {
            let clearImage = UIImage()
            self.setBackgroundImage(clearImage, for: .default)
            self.shadowImage = clearImage
            self.backgroundColor = .clear
            self.isTranslucent = true 
        }
        else
        {
            self.setBackgroundImage(nil, for: .default)
        }
    } 
}
