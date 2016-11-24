
import UIKit
import Material


// Const
fileprivate let kMenuTabSegue = "MenuTabSegue"

fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)
fileprivate let kBannerRatio: CGFloat = 16/9

fileprivate let kScrollStickRatio: CGFloat = 3/4
fileprivate let kAnimationDuration: TimeInterval = 0.25


/**
 * ViewController for a specific DiningHall, which includes:
 * - Banner image of the location
 * - Tabbed MealTypes containing TableView of DiningMenu 
 */
class DiningHallViewController: UIViewController, RequiresData, UIScrollViewDelegate, PageTabBarControllerDelegate
{
    // Data
    private var diningHall: DiningHall!
    

    // UI
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    @IBOutlet private weak var banner: UIImageView!
    private var bannerHeight: CGFloat!
    
    @IBOutlet private weak var scrollView: UIScrollView!
    private var nestedScrollView: UIScrollView!
    
    private var menuTabController: PageTabBarController! 
    private var menuTabView: UIView!
    private var menuTabBar: UIView!
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = DiningHall
    
    func setData(_ data: DiningHall)
    {
        self.diningHall = data
    }


    // ========================================
    // MARK: - UIViewController
    // ========================================
    /**
     * Setup and configure subcomponents.
     */
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
        
        // Manually call initial transition event.
        self.pageTabBarController(pageTabBarController: self.menuTabController, 
                                       didTransitionTo: self.menuTabController.viewControllers.first!)
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
        
        let viewBounds = self.view.bounds
        let viewSize = viewBounds.size
        
        // header
        self.bannerHeight = round(viewSize.width / kBannerRatio)
        self.banner.frame = CGRect(x: 0, y: 0, width: viewSize.width, height: self.bannerHeight)
        
        // menuTabView
        self.menuTabView.frame = viewBounds
        
        // scrollView
        self.scrollView.frame = viewBounds
        self.scrollView.contentInset.top = self.bannerHeight
        self.scrollView.contentSize = CGSize(width: viewSize.width, 
                                            height: self.menuTabBar.height + self.nestedScrollView.contentSize.height)
    }
    
    
    // ========================================
    // MARK: - Setup
    // ========================================
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
        
        banner.contentMode = .scaleAspectFill
        banner.load(url: diningHall.imageURL)
    }
    
    /**
     * Setup the scrollView that will contain the menuTabView
     */
    private func setupScrollView()
    {
        let scrollView = UIScrollView()
        scrollView.autoresizesSubviews = false
        scrollView.delegate = self
        
        self.view.addSubview(scrollView)
        self.scrollView = scrollView
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
        else { return }
    
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
    }
    
    
    // ========================================
    // MARK: - PageTabBarControllerDelegate
    // ========================================
    /**
     * Called when the menuTabControlle switches to a different DiningMenuViewController.
     */
    func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController)
    {
        guard
            let menuVC = viewController as? DiningMenuViewController,
            pageTabBarController == self.menuTabController
        else 
        { return }
        
        self.nestedScrollView = menuVC.tableView
        self.view.setNeedsLayout()
    }
    
    
    // ========================================
    // MARK: - UIScrollViewDelegate
    // ========================================
    private var startingOffsetY: CGFloat = 0
    
    // Store the offset at the start of scroll.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        self.startingOffsetY = scrollView.contentOffset.y
    }
    
    // Adjust the subcomponent frames and offsets depending on the outer scrollView. 
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let inset = scrollView.contentInset.top
        let offsetY = scrollView.contentOffset.y
        
        // If scrollView is pulled down, increase banner height accordingly.
        let pulled = -(inset + offsetY)
        self.banner.height = inset + (pulled > 0 ? pulled : 0)
        
        let adjustedOffset = (offsetY < 0) ? 0 : offsetY
        self.menuTabView.y = adjustedOffset
        self.nestedScrollView.contentOffset.y = adjustedOffset
        

        // Detect end of scrolling (http://stackoverflow.com/a/1857162)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(scrollViewDidEndScrollingAnimation(_:)), with: scrollView, afterDelay: 0.2)
    }
    
    // If scrolling ends within header area, scroll back or to top depending on direction of scroll.
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        let inset = scrollView.contentInset.top
        let offsetY = scrollView.contentOffset.y
        
        if (-inset < offsetY && offsetY < 0)
        {
            let finalY = (offsetY > self.startingOffsetY) ? 0 : -inset
            let duration = kAnimationDuration * Double( abs((finalY - offsetY) / inset) ) 
            
            UIView.animate(withDuration: duration)
            {
                scrollView.contentOffset = CGPoint(x: 0, y: finalY)
            }
        }
    }
}
