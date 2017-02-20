
import UIKit
import Material

fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)

/**
 *
 */
class DiningHallViewController: UIViewController, ResourceDetailProvider, RequiresData
{
    private var hall: DiningHall!
    
    private var menuTabController: PageTabBarController!
    private var menuTabBar: PageTabBar
    {
        return menuTabController.pageTabBar
    }
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = DiningHall
    
    func setData(_ data: DataType)
    {
        hall = data
        
        self.title = hall.name
    }
    
    
    // ========================================
    // MARK: - ResourceDataProvider
    // ========================================
    var viewController: UIViewController { return self }
    
    var imageURL: URL? { return hall?.imageURL }
    var text1: String? { return nil } // address
    var text2: String? { return nil } // open status
    
    var buttons: [UIButton]
    {
        let sort = IconButton(image: #imageLiteral(resourceName: "ic_sort_white"), tintColor: .white)
        sort.addTarget(self, action: #selector(sortTapped), for: .touchUpInside)
        
        return [sort]
    }
    
    var contentSize: CGSize = CGSize.zero
    var contentOffset: CGPoint
    {
        get { return CGPoint.zero }
        set { setContentOffset(newValue, animated: false) }
    }
    
    func setContentOffset(_ offset: CGPoint, animated: Bool)
    {
        
    }
    
    
    // ========================================
    // MARK: - UIViewController
    // ========================================
    
    override func viewDidLoad() 
    {
        super.viewDidLoad()
        
        setupMenus()
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
    }
    
    
    
    // ========================================
    // MARK: - Private
    // ========================================
    
    private func setupMenus()
    {
        let menuID = className(DiningMenuViewController.self)
        let viewControllers: [UIViewController] = MealType.allValues.map
        { type in
            
            let vc = storyboard!.instantiateViewController(withIdentifier: menuID) as! DiningMenuViewController
            vc.setData(type: type, shift: hall.meals[type]!)
            
            let barItem = vc.pageTabBarItem
            barItem.titleColor = kColorNavy
            barItem.pulseColor = kColorNavy//UIColor.white
            barItem.title = type.name
            
            return vc
        }
        
        menuTabController = PageTabBarController(viewControllers: viewControllers, selectedIndex: 0)
        menuTabController.pageTabBarAlignment = .top
        //menuTabController.delegate = self
        
        let tabBar = menuTabController.pageTabBar
        tabBar.backgroundColor = UIColor.white//kColorNavy
        tabBar.lineColor = kColorNavy//UIColor.white
        tabBar.lineHeight = 1
        tabBar.lineAlignment = .bottom
        
        let menus = menuTabController.view!
        menus.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addChildViewController(menuTabController)
        view.addSubview(menus)
    }
    
    func sortTapped()
    {
        
    }
}
