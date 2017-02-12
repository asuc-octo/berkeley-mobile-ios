
/**
 * Conforming modules are favorable, or can be favorited.
 * All Favorable items have a name, and indicated whether it's current Favorited. 
 */
protocol Favorable 
{
    var name: String { get }
    var isFavorited: Bool { get set }
    
    // TODO: create a parent protocol CategorySortable, 
    // indicating Favorables are sorted by name or favorites. 
}
