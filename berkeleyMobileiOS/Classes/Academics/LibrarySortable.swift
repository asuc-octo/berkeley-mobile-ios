/**
 * Defines possible sorting orders for libraries.
 * The `comparator` property returns a weak less than comparator function corresponding to the ordering option:
 *
 * - alphabetical  sorts only by name
 * - favorites     prioritizes favorited libraries, then by open, then by name
 * - open          prioritizes open libraries, then by name
 */
enum LibrarySortBy: String
{
    case alphabetical
    case favorites
    case open
    
    typealias Comparator = (Library, Library) -> Bool
    
    var comparator: Comparator
    {
        let byName: Comparator = { (a, b) in a.name <= b.name }
        
        let byOpen: Comparator = { (a, b) in (a.isOpen == b.isOpen) ? byName(a, b) : a.isOpen }
        
        let byFavorite: Comparator = { (a, b) in (a.isFavorited == b.isFavorited) ? byOpen(a, b) : a.isFavorited }
        
        switch self {
        case .alphabetical:
            return byName
        case .favorites:
            return byFavorite
        default:
            return byOpen
        }
    }
}
