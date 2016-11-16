
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
class DiningHallViewController: UIViewController
{
    // UI
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    @IBOutlet weak var navItem: UINavigationItem?
    @IBOutlet weak var banner: UIImageView?
    
    private var menuTabController: PageTabBarController? 
    private var menuTabView: UIView?
    
    // Data
    var diningHall: DiningHall? = nil
    

    // MARK: - UIViewController
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupHeader()
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
        
        let viewSize = self.view.bounds.size
        
        // layout banner image
        var bannerFrame = CGRect.zero
        bannerFrame.size = CGSize(width: viewSize.width, height: viewSize.width / kBannerRatio)
        self.banner?.frame = bannerFrame
        
        // layout MenuTabView
        var tabViewFrame = CGRect.zero
        tabViewFrame.origin.y = bannerFrame.maxY
        tabViewFrame.size.width = viewSize.width
        tabViewFrame.size.height = viewSize.height - bannerFrame.size.height
        self.menuTabView?.frame = tabViewFrame 
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
    
    /**
     * Setup the MenuTabView to display all MealTypes.
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
            
            let vc = storyboard.instantiateViewController(withIdentifier: "DiningMenuListViewController") as! DiningMenuListViewController
            vc.setData(type: type, menu: diningHall.menuForType(type))
            
            return vc
        }
        
        // Programmatically initialize PageTabBarController
        // External Bug: VCs written in Swift with @objc shows 'Unknown class <Class> in Interface Builder file' when used in storyboards
        let menuTabController = PageTabBarController(viewControllers: menuListVCs, selectedIndex: 0)
        menuTabController.pageTabBarAlignment = .top
        
        let menuTabView = menuTabController.view!
        
        let tab = menuTabController.pageTabBar
        tab.backgroundColor = kColorNavy
        tab.lineColor = UIColor.white
        tab.lineAlignment = .bottom
        tab.divider.thickness = 0
        
        self.addChildViewController(menuTabController)
        self.view.addSubview(menuTabView)
        
        self.menuTabController = menuTabController
        self.menuTabView = menuTabController.view
    }
}
