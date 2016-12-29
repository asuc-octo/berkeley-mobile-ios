
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
class DiningHallViewController: UIViewController, RequiresData, PageTabBarControllerDelegate, UIScrollViewDelegate
{
    // Data
    private var diningHall: DiningHall!
    

    // UI
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private weak var navbar: UINavigationBar?
    
    @IBOutlet private weak var banner: UIImageView!
    private var imageGradient: CAGradientLayer!
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupHeader()
        self.setupScrollView()
        self.setupMenuTabView()
        
        self.navbar = self.navigationController?.navigationBar
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setStatusBarStyle(self.preferredStatusBarStyle)
        self.navbar?.hideHairline = true
        self.navbar?.setTransparent(true)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // Manually call initial transition event.
        self.pageTabBarController(pageTabBarController: self.menuTabController, 
                                  didTransitionTo: self.menuTabController.viewControllers.first!)
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        self.navbar?.hideHairline = false
        self.navbar?.setTransparent(false)
    }
    
    /// Layout the subcomponents.
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let viewBounds = self.view.bounds
        let viewSize = viewBounds.size
        
        // header
        self.bannerHeight = round(viewSize.width / kBannerRatio) + 56
        self.banner.frame = CGRect(x: 0, y: 0, width: viewSize.width, height: self.bannerHeight)
        self.imageGradient.frame = self.banner.bounds
        
        // menuTabView
        self.menuTabView.frame = viewBounds
        
        // scrollView
        self.scrollView.frame = viewBounds
        self.scrollView.contentInset.top = self.bannerHeight
    }
    
    
    // ========================================
    // MARK: - Setup
    // ========================================
    
    /// Setup the header part of the view, including navbar and banner image.
    private func setupHeader()
    {
        self.banner.load(url: self.diningHall.imageURL)
    
        let gradient = CAGradientLayer()
        gradient.locations = [0, 0.5]
        gradient.colors = [UIColor(white: 0, alpha: 0.75).cgColor, UIColor.clear.cgColor]
        
        self.imageGradient = gradient
        self.banner.layer.addSublayer(gradient)
    }
    
    /// Setup the scrollView that will contain the menuTabView.
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
     * Must be called after scrollView has be initialized.
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
        else 
        { return }
    
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
        tabBar.backgroundColor = UIColor.white//kColorNavy
        tabBar.lineColor = kColorNavy//UIColor.white
        tabBar.lineHeight = 1
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
    
    /// Called when the menuTabControlle switches to a different DiningMenuViewController.
    func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController)
    {
        guard
            let menuVC = viewController as? DiningMenuViewController,
            pageTabBarController == self.menuTabController
        else 
        { return }
        
        // Reset offset of previous inner scrollView (if any), and set new one.
        self.nestedScrollView?.contentOffset = CGPoint.zero
        self.nestedScrollView = menuVC.tableView
        
        let inset = self.scrollView.contentInset.top
        let offsetY = self.scrollView.contentOffset.y
        
        // Calculate new offset and contentSize.
        let finalY = (offsetY < 0) ? -inset : 0;
        var contentHeight =  self.menuTabBar.height + self.nestedScrollView.contentSize.height
        
        if (contentHeight == self.menuTabBar.height) && (offsetY >= 0)
        {
            // But if there is no nested content and tabBar is already sticked to top,
            // give enough height to be scrollable down. 
            contentHeight = self.menuTabView.height
        }
        
        self.scrollView.contentSize = CGSize(width: self.view.width, height: contentHeight)
        self.scrollView.contentOffset = CGPoint(x: 0, y: finalY)
    }
    
    
    // ========================================
    // MARK: - UIScrollViewDelegate
    // ========================================
    private var startingOffsetY: CGFloat = 0
    
    /// Store the offset at the start of scroll.
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    {
        self.startingOffsetY = scrollView.contentOffset.y
    }
    
    /// Adjust the subcomponent frames and offsets depending on the outer scrollView. 
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let inset = scrollView.contentInset.top
        let offsetY = scrollView.contentOffset.y
        
        // If scrollView is pulled down, increase banner height accordingly.
        let pulled = -(inset + offsetY)
        self.banner.height = inset + (pulled > 0 ? pulled : 0)
        
        let adjustedOffset = (offsetY < 0) ? 0 : offsetY
        self.menuTabView.y = adjustedOffset
        self.nestedScrollView?.contentOffset.y = adjustedOffset
        

        // Detect end of scrolling (http://stackoverflow.com/a/1857162)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(scrollViewDidEndScrollingAnimation(_:)), with: scrollView, afterDelay: 0.2)
    }
    
    /**
     * Called when the scrollView has completely stopped scrolling. 
     * Any scrolling done within this method will cause it be called again.
     * 
     * - If scroll ended within the header, snap it to the top or bottom depending on the scroll direction.
     * - Adjust contentSize if banner is showing. 
     *       When the menu page is changed while scrolled up, it should stay scrolled up for usability.
     *       But after scrolling down, should not be able to scroll back up if not enough content.
     */
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        let inset = scrollView.contentInset.top
        let offsetY = scrollView.contentOffset.y
        
        // If within header, snap to top or bottom.
        if (-inset < offsetY && offsetY < 0)
        {
            let finalY = (offsetY > self.startingOffsetY) ? 0 : -inset
            let duration = kAnimationDuration * Double( abs((finalY - offsetY) / inset) ) 
            
            // Animation duration depends on the the distance.
            UIView.animate(withDuration: duration)
            {
                scrollView.contentOffset = CGPoint(x: 0, y: finalY)
            }
        }
        
        // If scrolled to bottom and no content, adjust parent scrollView's contentSize.
        let contentHeight = self.nestedScrollView?.contentSize.height
        if (offsetY == -inset) && (contentHeight == 0)
        {
            self.scrollView.contentSize.height = self.menuTabBar.height
        }
    }
}
