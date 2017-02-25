
/**
 * Indicates that the conforming type can be favorited.
 * All `Favorable` instances must have a string name, and a boolean flag of the status.
 */
protocol Favorable 
{
    var name: String { get }
    var isFavorited: Bool { get set }
}


/**
 * Defines possible sorting orders for elements conforming to `Favorable`.
 * The `comparator` property returns a weak less than comparator function corresponding to the ordering option:
 *
 * - alphabetical  sorts only by name
 * - favorites     prioritizes favorited elements, then by name
 */
enum FavorableSortBy: String
{
    case alphabetical
    case favorites
    
    typealias Comparator = (Favorable, Favorable) -> Bool
    
    var comparator: Comparator
    {
        let byName: Comparator = { $0.0.name <= $0.1.name }
        
        return (self == .alphabetical) ? byName :
        { (a, b) in 
        
            return (a.isFavorited == b.isFavorited) ? byName(a, b) : a.isFavorited
        }
    }
}
