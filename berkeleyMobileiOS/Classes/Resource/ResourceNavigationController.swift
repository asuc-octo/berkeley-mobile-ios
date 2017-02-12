
import UIKit

/**
 *
 */
class ResourceNavigationController: UINavigationController, RequiresData
{    
    
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
    
    func setData(_ type: DataType)
    {
        let name = type.rawValue.lowercased()
        self.pageTabBarItem.image = UIImage(named: "ic_tab_" + name)?.withRenderingMode(.alwaysTemplate)
        
        let rootVC = self.viewControllers.first as? ResourceGroupViewController
        rootVC?.setData(type)
    }
}
