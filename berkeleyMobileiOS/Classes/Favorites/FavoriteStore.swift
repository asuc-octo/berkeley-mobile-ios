
import Foundation
import RealmSwift


/// Global, but private, Realm.
fileprivate let realm = try! Realm()

/// Represents a single favorited item (or location).
class FavoriteItem: RealmSwift.Object
{
    dynamic var type: String = ""
    dynamic var name: String = ""
}

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
    
    /// Add item of given type and name.
    func add(type: AnyClass, name: String)
    {
        let item = FavoriteItem(value: ["type": String(describing: type), "name": name])
        
        try! realm.write
        {
            realm.add(item)
        }
    }
    
    /// Remove item of given type and name.
    func remove(type: AnyClass, name: String)
    {
        let result = self.query(type, name)
        
        if result.count == 1
        {
            try! realm.write {
                realm.delete(result.first!)
            }
        }
    }
    
    /// Returns whether item of given type and name is favorited.
    func contains(type: AnyClass, name: String) -> Bool
    {
        let result = self.query(type, name)
        
        return result.count == 1
    }
    
    /// Return a String array containing all favorited items of the specified class. 
    func allItemsOfType(_ type: AnyClass) -> [String]
    {
        let result = realm.objects(FavoriteItem.self).filter("type = '\( String(describing: type) )'")
        return result.map { return $0.name }
    }
    
    
    private func query(_ type: AnyClass, _ name: String) -> Results<FavoriteItem>
    {
        return realm.objects(FavoriteItem.self).filter("type = '\( String(describing: type) )' and name = '\(name)'")
    }
}
