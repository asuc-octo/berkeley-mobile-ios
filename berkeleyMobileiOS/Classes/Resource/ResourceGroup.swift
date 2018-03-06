
import UIKit

/**
 * **ResourceGroup** is a collection of `Resource` types.
 */
struct ResourceGroup
{
    let name: String
    let icon: UIImage
    let types: [Resource.Type]
    
    fileprivate init(name: String, icon: UIImage, types: [Resource.Type])
    {
        self.name = name
        self.icon = icon.withRenderingMode(.alwaysTemplate)
        self.types = types
    }
    
    
    // MARK: - Groups
//    static let all = [academics, dining, recreation]
    static let all = [dining, recreation]
    static let academics = ResourceGroup(
        name: "Academics",
        
        icon: #imageLiteral(resourceName: "library_transparent"),
        types: [
            Library.self, 
            CampusResource.self
        ]
    )
    
    static let dining = ResourceGroup(
        name: "Dining", 
        icon: #imageLiteral(resourceName: "DINING"), 
        types: [
            DiningHall.self,
            CafeClass.self
        ]
    )
    
    static let recreation = ResourceGroup(
        name: "Recreation",
        icon: #imageLiteral(resourceName: "gym-uncolored"),
        types: [
            Gym.self,
            GymClass.self
        ]
    )

}
