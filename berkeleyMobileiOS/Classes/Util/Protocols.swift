
import Foundation
import UIKit

extension UIViewController
{
    var storyboardID: String {
        get { return "\(type(of: self))" }
    }
}
