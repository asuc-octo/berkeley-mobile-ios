
import Foundation
import UIKit

/**
 * Protocol for `UIViewController` subclasses passed into `ResourceContainerController`. 
 * 
 * Conforming modules must provide all visual elements including:
 * - Title and subtexts for `InfoPanel`
 * - Banner image
 * - Buttons for the right side of the `Toolbar`
 *
 * It can also optionally implement `UIScrollViewDelegate` methods, 
 * which will be called after the containing module has handled it first.
 */
protocol ResourceDetailProvider: DelegatesScroll
{
    var viewController: UIViewController { get }

    var text1: String? { get }
    var text2: String? { get }
    var imageURL: URL? { get }
    var buttons: [UIButton] { get }
}
