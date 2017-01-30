
import UIKit

/**
 * Specifies that the implementing module require data of DataType (which is defined by each module),
 * otherwise object may error or not behave properly.
 */
protocol RequiresData
{
    associatedtype DataType
    
    mutating func setData(_ data: DataType)
}


/**
 * Specifies that the implementing module contains an UIScrollView,
 * whose scrolling is open to external control that may not be user input.
 */
protocol DelegatesScroll
{
    /// Get the contentSize property of the internal UIScrollView.
    var contentSize: CGSize { get }

    /// Get/Set the contentOffset property of the internal UIScrollView. 
    var contentOffset: CGPoint { get set }
    
    /// Set of setContentOffset method of the internal UIScrollView.
    func setContentOffset(_ offset: CGPoint, animated: Bool)
}
