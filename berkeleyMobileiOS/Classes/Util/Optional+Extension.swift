
import Foundation

/**
 * Provides .isNil and .notNil for quicker optional nil checking.
 */
extension Optional
{
    var isNil: Bool
    {
        get {
            return self == nil
        }
    }
    
    var notNil: Bool
    {
        get {
            return self != nil
        }
    }
}
