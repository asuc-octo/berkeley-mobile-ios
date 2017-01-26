
import Foundation
import RealmSwift

/**
 * FavoriteStore is a singleton that keeps track of favorited items for this device, 
 * regardless of the type (e.g. Dining Hall, Gym, Library, etc).
 * 
 * - Note: 
 *   Favorites should be managed through the public interface of this class,
 *   since the underlying implementation/module might change.
 */
class FavoriteStore
{
    // Singleton
    static let sharedInstance = FavoriteStore()
    private init() {}

    
    // Definition
    let realm = try! Realm()
    
    func add(type: AnyClass, name: String)
    {
        write(type, name, true)
    }
    
    func remove(type: AnyClass, name: String)
    {
        write(type, name, false)
    }
    
    /// Return a String array containing all favorited items of the specified class. 
    func allItemsOfType(_ type: AnyClass) -> [String]
    {
        let result = realm.objects(Item.self).filter("type = '\( String(describing: type) )'")
        return result.map { return $0.name }
    }
    
    
    private func write(_ type: AnyClass, _ name: String, _ add: Bool)
    {
        let item = Item(value: ["type": String(describing: type), "name": name])
        
        try! realm.write
        {
            add ? realm.add(item) : realm.delete(item)
        }
    }
}


/// Represents a single favorited item (or location).
fileprivate class Item: RealmSwift.Object
{
    dynamic var type: String = ""
    dynamic var name: String = ""
}
