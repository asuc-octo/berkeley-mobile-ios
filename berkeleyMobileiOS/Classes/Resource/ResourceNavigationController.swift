
import UIKit

/**
 * Base navigation controller for a single type of `Resource`.
 */
class ResourceNavigationController: UINavigationController, IBInitializable
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
    func setGroup(_ group: ResourceGroup)
    {
        pageTabBarItem.image = group.icon 
        
        let groupVC = viewControllers.first as? ResourceGroupViewController
        groupVC?.setGroup(group)
    }
}
