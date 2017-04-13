
import UIKit

 
// Store keeps a mapping from storyboard name to instance.
// Function instance() is for lazily initializing the instance.
// Assumes that search performance is negligible for the number of storyboards.
fileprivate var store = [String : UIStoryboard]()

fileprivate func instance(_ name: String, _ bundle: Bundle? = nil) -> UIStoryboard
{
    var sb = store[name]
    guard sb != nil else
    {
        sb = UIStoryboard(name: name, bundle: bundle)
        store[name] = sb
    }
    
    return sb!
}


/**
 * Extension for `UIStorboard` with project storyboards as proparties.
 * The instances are lazily initialized.
 */
extension UIStoryboard
{
    static var main = instance("Main")
}
