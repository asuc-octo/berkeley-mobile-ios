
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
protocol ResourceDetailProvider: class, DelegatesScroll
{
    static func newInstance() -> ResourceDetailProvider
    
    var viewController: UIViewController { get }

    var text1: String? { get }
    var text2: String? { get }
    var imageURL: URL? { get }
    var buttons: [UIButton] { get }
    
    /// Whether the receiving container should reset content offset when content size is changed.
    var resetOffsetOnSizeChanged: Bool { get }
    
    /**
     * Handler to be called by implementing module when underlying `contentSize` changes.
     * Whoever is receiving the event will determine the new scroll size and offset. 
     */
    var contentSizeChangeHandler: ((ResourceDetailProvider) -> Void)? { get set }
}
