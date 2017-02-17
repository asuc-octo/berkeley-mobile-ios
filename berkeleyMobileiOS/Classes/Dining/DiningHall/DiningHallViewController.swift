
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
    private var pseudoNavbar: UIView!
    private var scrollMinY: CGFloat! = 0
    
    @IBOutlet private weak var banner: UIImageView!
    private var imageGradient: CAGradientLayer!
    
    @IBOutlet private weak var scrollView: UIScrollView!
    private var nestedScrollView: DelegatesScroll!
    
    private var menuTabController: PageTabBarController! 
    private var menuTabView: UIView!
    private var menuTabBar: UIView!
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = DiningHall
    
    /// Store the DiningHall and set the name.
    func setData(_ hall: DiningHall)
    {
        self.diningHall = hall
        self.title = hall.name
    }


    // ========================================
    // MARK: - UIViewController
    // ========================================
    
    /// Call all necessary setup methods and store a reference to the UINavigationBar.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupHeader()
        self.setupScrollView()
        self.setupMenuTabView()
        
        self.navbar = self.navigationController?.navigationBar
    }
    
    /// Configure the UINavigationBar.
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navbar?.hideHairline = true
        self.navbar?.setTransparent(true)
        setStatusBarStyle(self.preferredStatusBarStyle)
    }
    
    /// Manually call the initial pageTabBar transition callback.
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.pageTabBarController(pageTabBarController: self.menuTabController, 
                                  didTransitionTo: self.menuTabController.viewControllers.first!)
    }
    
    /// Layout the subcomponents.
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let view = self.view!
        
        // Reset the navbar's Y to scrollView's offset. 
        let navbarMaxY = self.navbar?.frame.maxY ?? 0
        let navbarY = min(self.scrollView.contentOffset.y, 0)
        self.pseudoNavbar.frame = CGRect(x: 0, y: navbarY, width: view.width, height: navbarMaxY)
        
        // header
        self.banner.frame = CGRect(x: 0, y: 0, width: view.width, height: round(view.width / kBannerRatio) + navbarMaxY)
        self.imageGradient.frame = self.banner.bounds
        
        // menuTabView (inside scrollView)
        var frame = CGRect(x: 0, y: 0, width: view.width, height: view.height - navbarMaxY)
        self.menuTabView.frame = frame
        
        // scrollView
        frame.origin.y = navbarMaxY
        self.scrollView.frame = frame
        self.scrollView.contentInset.top = self.banner.height - navbarMaxY
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
        
        // Pseudo navbar background.
        self.pseudoNavbar = UIView()
        self.pseudoNavbar.backgroundColor = kColorNavy
        self.view!.addSubview(self.pseudoNavbar)
    }
    
    /// Setup the scrollView that will contain the menuTabView.
    private func setupScrollView()
    {
        scrollView.autoresizesSubviews = false
        scrollView.delegate = self
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
            vc.setData(type: type, shift: diningHall.meals[type]!)
            
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
            let containsScroll = viewController as? DelegatesScroll,
            pageTabBarController == self.menuTabController
        else 
        { return }
        
        // Reset offset of previous inner scrollView (if any), and set new one.
        self.nestedScrollView?.contentOffset = CGPoint.zero
        self.nestedScrollView = containsScroll
        
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
        self.banner.height = inset + (pulled > 0 ? pulled : 0) + (self.navbar?.frame.maxY ?? 0)
        
        // Scroll up until offset 0, then sticky the menuTabView and scroll the nested scrollView instead. 
        let nestedOffset = (offsetY < 0) ? 0 : offsetY
        self.menuTabView.y = nestedOffset
        self.nestedScrollView?.contentOffset.y = nestedOffset
        
        
        // When scrolled up, pseudoNavbar shows itself
        self.pseudoNavbar.y = min(offsetY, 0) // slide down from top
//        self.pseudoNavbar.alpha = min(inset + offsetY, inset) / inset // clear -> opaque

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
