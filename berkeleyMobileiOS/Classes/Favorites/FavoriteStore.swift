
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
    static let shared = FavoriteStore()
    private init() {}
    
    /// Add item of given type and name.
    func add(_ item: Favorable)
    {
        let item = FavoriteItem(value: ["type": typeString(forItem: item), "name": item.name])
        
        try! realm.write
        {
            realm.add(item)
        }
    }
    
    /// Remove item of given type and name.
    func remove(_ item: Favorable)
    {
        let result = self.query(item)
        
        if result.count == 1
        {
            try! realm.write {
                realm.delete(result.first!)
            }
        }
    }
    
    /// Returns whether item of given type and name is favorited.
    func contains(_ item: Favorable) -> Bool
    {
        return query(item).count == 1
    }
    
    /// Return a String array containing all favorited items of the specified class. 
    func allItemsOfType(_ type: AnyClass) -> [String]
    {
        let result = realm.objects(FavoriteItem.self).filter("type = '\( String(describing: type) )'")
        return result.map { return $0.name }
    }
    
    /// Restores the favorited state for given `Favorable` item.
    func restoreState(for item: Favorable)
    {
        var item = item
        item.isFavorited = contains(item)
    }
    
    
    private func query(_ item: Favorable) -> Results<FavoriteItem>
    {
        return realm.objects(FavoriteItem.self).filter("type = '\( typeString(forItem: item) )' and name = '\(item.name)'")
    }
    
    private func typeString(forItem item: Favorable) -> String
    {
        return String(describing: item.self)
    }
}
