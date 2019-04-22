
import UIKit

/**
 * Base navigation controller for a single type of `Resource`.
 */

fileprivate let kColorNavy = UIColor(red: 0, green: 51/255.0, blue: 102/255.0, alpha: 1)

class ResourceNavigationController: UINavigationController, IBInitializable, TabBarControllerView
{
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    // ========================================
    // MARK: - TabBarControllerView
    // ========================================
    var tabBarIcon: UIImage? { return pageTabBarItem.image }
    
    
    // ========================================
    // MARK: - IBInitializable
    // ========================================
    typealias IBComponent = ResourceNavigationController
    
    class var componentID: String { return className(IBComponent.self) }
    
    class func fromIB() -> IBComponent
    {
        return UIStoryboard.resource.instantiateViewController(withIdentifier: self.componentID) as! IBComponent
    }
    
    
    // ========================================
    // MARK: - UINavigationController
    // ========================================
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationBar.barTintColor = kColorNavy
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "bearsmallmed"))
        imageView.contentMode = .scaleAspectFit
        topViewController?.navigationItem.titleView = imageView
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
