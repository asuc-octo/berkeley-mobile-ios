
import UIKit

extension UIViewController
{
    
    /**
     * Returns the current height of the status bar.
     * Take smaller of width and height, to account for the flipped fields during landscape mode.  
     */
    var statusBarHeight: CGFloat
    {
        let size = UIApplication.shared.statusBarFrame.size
        return min(size.width, size.height)
    }
}
