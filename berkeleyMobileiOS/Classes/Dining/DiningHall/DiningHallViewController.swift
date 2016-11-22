
import UIKit
import Material


// Const
fileprivate let kMenuTabSegue = "MenuTabSegue"

fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)
fileprivate let kBannerRatio: CGFloat = 16/9


/**
 * ViewController for a specific DiningHall, which includes:
 * - Banner image of the location
 * - Tabbed MealTypes containing TableView of DiningMenu 
 */
class DiningHallViewController: UIViewController, UIScrollViewDelegate, PageTabBarControllerDelegate
{
    // Data
    var diningHall: DiningHall? = nil
    

    // UI
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    @IBOutlet private weak var banner: UIImageView!
    
    private var scrollView: UIScrollView!
    private var childScrollView: UIScrollView!
    
    private var menuTabController: PageTabBarController! 
    private var menuTabView: UIView!
    private var menuTabBar: UIView!
    

    // MARK: - UIViewController
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupHeader()
        self.setupScrollView()
        self.setupMenuTabView()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setStatusBarStyle(self.preferredStatusBarStyle)
        self.navigationController?.navigationBar.hideHairline = true
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.hideHairline = false
    }
    
    /**
     * Layout components after defaults have been applied
     */
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let bounds = self.view.bounds
        let size = bounds.size
        
        // layout banner image
        var bannerFrame = CGRect.zero
        bannerFrame.size = CGSize(width: size.width, height: round(size.width / kBannerRatio))
        self.banner.frame = bannerFrame
        
        // layout MenuTabView
        self.menuTabView.frame = bounds
        
        
        // scrollView
        self.scrollView.frame = bounds
        self.scrollView.contentInset = UIEdgeInsetsMake(self.banner.height, 0, 0, 0)
        self.scrollView.contentSize = CGSize(width: size.width, height: self.menuTabBar.height + self.childScrollView.contentSize.height)
    }
    
    
    // MARK: - Setup
    /**
     * Setup the header part of the view, including navbar and banner image.
     */
    private func setupHeader()
    {
        guard 
            let diningHall = self.diningHall,
            let banner = self.banner 
        else {
            return
        }
    
        self.title = diningHall.name
        banner.load(url: diningHall.imageURL)
    }
    
    private func setupScrollView()
    {
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.autoresizesSubviews = false
        
        self.view.addSubview(self.scrollView)
    }
    
    /**
     * Setup the MenuTabView to display all MealTypes.
     * 
     * - NOTE
     * PageTabBarController is initialized programmatically due to iOS bug. 
     * ViewControllers written in Swift that use @objc throw an "Unknown class <Class> in Interface Builder file" when used in storyboards. 
     */
    private func setupMenuTabView()
    {
        guard 
            let storyboard = self.storyboard,
            let diningHall = self.diningHall 
        else {
            return
        }
    
        // Create a DiningMenuListVC for each MealType, and set it's data.
        let menuListVCs: [UIViewController] = MealType.allValues.map
        { type in 
            
            let vc = storyboard.instantiateViewController(withIdentifier: "DiningMenuViewController") as! DiningMenuViewController
            vc.setData(type: type, menu: diningHall.menuForType(type))
            
            return vc
        }
        
        // Initialize PageTabBarController and configure look.
        let tabController = PageTabBarController(viewControllers: menuListVCs, selectedIndex: 0)
        tabController.pageTabBarAlignment = .top
        tabController.delegate = self
        
        let tabBar = tabController.pageTabBar
        tabBar.backgroundColor = kColorNavy
        tabBar.lineColor = UIColor.white
        tabBar.lineAlignment = .bottom
        tabBar.divider.thickness = 0
        
        // Store references and add to hierarchy
        self.menuTabController = tabController
        self.menuTabView = tabController.view
        self.menuTabBar = tabBar
        
        self.addChildViewController(self.menuTabController)
        self.scrollView.addSubview(self.menuTabView)
        
        
        // Manually call initial transition event.
        self.pageTabBarController(pageTabBarController: self.menuTabController, didTransitionTo: menuListVCs.first!)
    }
    
    // MARK: - PageTabBarControllerDelegate
    /**
     * Called when the menuTabControlle switches to a different DiningMenuViewController.
     */
    func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController)
    {
        guard
            pageTabBarController == self.menuTabController,
            let menuVC = viewController as? DiningMenuViewController
        else {
            return
        }
        
        self.childScrollView = menuVC.tableView
        self.childScrollView.isScrollEnabled = false
        self.view.setNeedsLayout()
    }
    
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        print(scrollView.contentOffset.y)
    }
}
