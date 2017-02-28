
import UIKit

/**
 * Enum of all available `Resource` types.
 */
enum ResourceType: String
{
    case Gym
    case Library
    case DiningHall
    case CampusResource
    
    static let allValues = [Gym, Library, DiningHall]
    
    var dataSourceType: ResourceDataSource.Type
    {
        switch self 
        {
            case .Gym: return GymDataSource.self
            case .Library: return LibraryDataSource.self
            case .DiningHall: return DiningDataSource.self
            case .CampusResource: return CampusResourceDataSource.self
        }
    }
}

/**
 * A physical resource (e.g. libraries, dining halls) available to students.
 */
class Resource: Favorable
{
    var name: String
    var type: ResourceType
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
    
    init(name: String, type: ResourceType, imageLink: String?, favorited: Bool = false)
    {
        self.name = name
        self.imageURL = URL(string: imageLink ?? "")
        self.isFavorited = favorited
        self.type = type
    }
}
