
import UIKit
import Foundation

/**
 * **Resource** describes one thing (usually a building) available to students.
 */
protocol Resource: class, TypeString, Favorable
{
    // MARK: Class
    static func displayName(pluralized: Bool) -> String
    
    static var dataSource: ResourceDataSource.Type? { get }
    static var detailProvider: ResourceDetailProvider.Type? { get }
    
    
    // MARK: Instance
    var name: String { get }
    var imageURL: URL? { get }
    
    /// Whether this `Resource` is currently open.
    var isOpen: Bool { get }
    
    /// String description in the form "Type: name", for debugging purposes.
    var description: String { get }
}

// MARK: - Default Implementations
extension Resource
{
    var description: String
    {
        return "\(type(of: self)): \(self.name)"
    }
}
