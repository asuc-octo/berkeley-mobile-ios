
import UIKit
import Material

fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)

/**
 * `DiningHallViewController` displays the details of a single `DiningHall`.
 * 
 * This controller is designed to be placed within a `ResourceContainerController`, giving data as a `ResourceDetailProvider`.
 * The view only contains a tab pages of the menus, without showing any data about the `DiningHall` itself (e.g. names, times, etc).
 */
class DiningHallViewController: UIViewController, RequiresData, ResourceDetailProvider, PageTabBarControllerDelegate
{
    private var hall: DiningHall!
    
    private let sortMenuController = ListMenuController()
    private var menuTabController: PageTabBarController!
    private var menuTabBar: PageTabBar
    {
        return menuTabController.pageTabBar
    }
    
    private var selectedScroll: DelegatesScroll!
    
    
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
    
    // TODO: Fill real data here.
    var imageURL: URL? { return hall?.imageURL }
    var text1: String? { return nil } // address
    var text2: String? { return nil } // open status
    
    /// Buttons for the container to make available.
    var buttons: [UIButton]
    {
        let sort = IconButton(image: #imageLiteral(resourceName: "ic_sort"), tintColor: .white)
        sort.addTarget(self, action: #selector(sortTapped), for: .touchUpInside)
        
        return [sort]
    }
    
    /// Content size of the current menu tab page.
    var contentSize: CGSize
    {
        return selectedScroll.contentSize
    }
    
    /// Scroll for the current menu tab page not animated.
    var contentOffset: CGPoint
    {
        get { return selectedScroll.contentOffset }
        set { setContentOffset(newValue, animated: false) }
    }
    
    /// Set the scroll for the currently selected menu tab page.
    func setContentOffset(_ offset: CGPoint, animated: Bool)
    {
        selectedScroll?.setContentOffset(offset, animated: false)
    }
    
    /// Callback for when the internal `contentSize` has changed.
    var contentSizeChangeHandler: ((ResourceDetailProvider) -> Void)?
    
    
    // ========================================
    // MARK: - UIViewController
    // ========================================
    
    /// Call necessary setup methods.
    override func viewDidLoad() 
    {
        super.viewDidLoad()
        
        setupMenus()
        setupSortMenu()
    }
    
    /// Manually call the transition handler for initial page.
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // TODO: Check open hours, and appear on nearest meal.
        pageTabBarController(pageTabBarController: menuTabController, didTransitionTo: menuTabController.viewControllers.first!)
    }
    
    
    // ========================================
    // MARK: - PageTabBarControllerDelegate
    // ========================================
    
    /// When the page changes, set a new scroll, and call the `contentSizeChangeHandler`.
    func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController)
    {
        guard let scroll = viewController as? DelegatesScroll else
        {
            return
        } 
    
        selectedScroll = scroll
        contentSizeChangeHandler?(self)
    }
    
    
    // ========================================
    // MARK: - Private
    // ========================================
    
    /// Initialize and configure `DiningMenuViewControllers` to add as tab pages.
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
            barItem.titleLabel?.font = RobotoFont.regular(with: 16)
            
            return vc
        }
        
        
        menuTabController = PageTabBarController(viewControllers: viewControllers, selectedIndex: 0)
        menuTabController.pageTabBarAlignment = .top
        menuTabController.delegate = self
        
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
    
    /// Intialize and configure the modal `ListMenuController` for sorting options.
    private func setupSortMenu()
    {
        typealias handlerType = (ListMenuItem) -> Void
    
        let menu = sortMenuController
        menu.message = "Sort by"
        
        let dismissMenu: handlerType = { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        
        let selected: handlerType = {
            menu.setItem($0, selected: true, clearOthers: true)
            dismissMenu($0)
        }
        
        sortMenuController.addItem(ListMenuItem(text: "Alphabetical", icon: #imageLiteral(resourceName: "ic_sort_by_alpha"), tint: Color.blue.darken1, selected: false, handler: selected))
        sortMenuController.addItem(ListMenuItem(text: "Favorites", icon: #imageLiteral(resourceName: "ic_favorite"), tint: Color.pink.base, selected: true, handler: selected))
        sortMenuController.addItem(ListMenuItem(text: "Cancel", icon: #imageLiteral(resourceName: "ic_close"), tint: .black, selected: false, handler: dismissMenu))
    }
    
    /**
     * Called when the sort button (given through `ResourceDetailProvider`) is tapped.
     * Present the menu through the parent if there is one; otherwise through itself.
     */
    func sortTapped()
    {
        let presentingVC = self.parent ?? self
        presentingVC.present(sortMenuController, animated: true, completion: nil)
    }
}
