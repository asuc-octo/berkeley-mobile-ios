
import UIKit

/**
 * Enum of all available `Resource` types.
 */
enum ResourceType: String
{
    case Gym
    case GymClass
    case Library
    case DiningHall
    
    static let allValues = [Gym, Library, DiningHall]
    static let connections: [ResourceType: [ResourceType]] = [Gym: [Gym, GymClass], Library: [Library], DiningHall: [DiningHall]]
//    static let k = {Gym: [Gym, GymClass]}
    
    var dataSourceType: ResourceDataSource.Type
    {
        switch self 
        {
            case .Gym: return GymDataSource.self
            case .Library: return LibraryDataSource.self
            case .DiningHall: return DiningDataSource.self
            case .GymClass: return GymClassDataSource.self

        }
    }
}


/**
 * A physical resource (e.g. libraries, dining halls) available to students.
 */
class Resource: Favorable
{
    var name: String
    var imageURL: URL? // TODO: consider an array/collection of images.
    
    var isFavorited: Bool
    
    // TODO: Move properties of `CampusResource` here
    
    // TODO: consider a protocol approach.
    var isOpen: Bool
    {
        return false
    }
    
    /// String description is simply "DiningHall <name>"
    var description: String
    {
        return "\( type(of: self) ): \(self.name)"
    }
    
    init(name: String, imageLink: String?, favorited: Bool = false)
    {
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
        self.isFavorited = favorited
    }
}
