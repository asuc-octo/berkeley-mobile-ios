
import UIKit

/**
 * Base navigation controller for a single type of `Resource`.
 */
class ResourceNavigationController: UINavigationController, IBInitializable, RequiresData
{ 
    // ========================================
    // MARK: - IBInitializable
    // ========================================
    typealias IBComponent = ResourceNavigationController
    
    static var componentID: String { return className(IBComponent.self) }
    
    static func fromIB() -> IBComponent 
    {
        return UIStoryboard.resource.instantiateViewController(withIdentifier: self.componentID) as! IBComponent
    }
    
    
    // ========================================
    // MARK: - UINavigationController
    // ========================================
    
    override func awakeFromNib()
    {
        self.pageTabBarItem.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.pageTabBarController?.highlightTabItem(of: self)
    }
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = ResourceType
    
    /// Requires the `ResourceType` to display.
    func setData(_ type: DataType)
    {
        let name = type.rawValue.lowercased()
        self.pageTabBarItem.image = UIImage(named: "ic_tab_" + name)?.withRenderingMode(.alwaysTemplate)
        
        let rootVC = self.viewControllers.first as? ResourceGroupViewController
        rootVC?.setData(type)
    }
}
