
import UIKit

/// `CATransaction` extension with utility static functions.
extension CATransaction
{

    /// Execute the given `updates()` with default CA animation disabled.
    static func performWithoutAnimation(_ updates: (() -> Void))
    {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        updates()
        
        CATransaction.commit()
    }
}
