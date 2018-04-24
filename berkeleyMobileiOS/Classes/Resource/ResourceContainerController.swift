
import UIKit
import Material

fileprivate let kToolBarHeight: CGFloat = 56.0
fileprivate let kStatusBarHeight: CGFloat = 20.0

fileprivate let kBannerRatio: CGFloat = 16/7
fileprivate let kAnimationDuration: TimeInterval = 0.25



/**
 * 
 */
class ResourceContainerController: UIViewController, IBInitializable, UIScrollViewDelegate
{    
    // UI
    private let toolbar = FadeTitleToolbar()
    
    @IBOutlet private var banner: UIImageView!
    private let bannerGradient = CAGradientLayer()
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var infoPanel: InfoPanel!
    
    
    // ========================================
    // MARK: - IBInitializable
    // ========================================
    typealias IBComponent = ResourceContainerController
    
    static var componentID: String { return className(IBComponent.self) }
    
    static func fromIB() -> IBComponent
    {
        return UIStoryboard.resource.instantiateViewController(withIdentifier: self.componentID) as! IBComponent
    }
    
    
    // ========================================
    // MARK: - ResourceDetail
    // ========================================
    var detailProvider: ResourceDetailProvider! = nil
    {
        didSet {
            addChildViewController(detailViewController)
        }
    }
    
    private var detailViewController: UIViewController 
    { 
        return detailProvider.viewController 
    }
    
    private var detailView: UIView
    { 
        return detailProvider.viewController.view
    }
    
    
    // ========================================
    // MARK: - UIViewController
    // ========================================
    
    /// Call all necessary setup methods.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.clipsToBounds = true
        
        setupToolbar()
        setupBanner()
        setupScrollView()
        if let im = detailProvider.resource.image {
            banner.image = im
        } else {
            banner.load(resource: detailProvider.resource)
        }
        titleLabel.text = detailViewController.title
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 25, weight: UIFontWeightBold)
        infoPanel.isHidden = true
        infoPanel.title = detailViewController.title
        infoPanel.text1 = detailProvider.text1
        infoPanel.text2 = detailProvider.text2
//        toolbar.isHidden = true
        toolbar.title = detailViewController.title
        toolbar.rightViews = detailProvider.buttons
        toolbar.rightViews.forEach
        {
            $0.tintColor = .white
            $0.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        }
        
        detailProvider.contentSizeChangeHandler = contentSizeDidChange
    }
    
    /**
     * By the time view want's to layout its subviews, the bounds is correct.
     * Before calling layoutSubviews() on each child, give it the correct size.
     */
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        let size = view.frame.size
        let toolbarBottom = statusBarHeight + kToolBarHeight
        
        // Banner goes under the status and toolbars. 
        let bannerHeight = toolbarBottom + round(size.width / kBannerRatio)
        banner.frame = CGRect(x: 0, y: 0, width: size.width, height: bannerHeight)
        bannerGradient.frame = banner.bounds
        
        titleLabel.frame = CGRect(x: 10, y: 200, width: size.width - 20, height: 30)
        
        scrollView.frame = CGRect(x: 0, y: toolbarBottom, width: size.width, height: size.height - toolbarBottom)
        scrollView.contentInset.top = banner.frame.maxY - toolbarBottom
//        scrollView.contentOffset = CGPoint(x: 0, y: InfoPanel.fixedHeight)
//        if (type(of: self.detailProvider!) == berkeleyMobileiOS.GymClassViewController.self) {
//            scrollView.contentOffset = CGPoint(x:0, y: 0)
//            toolbar.reveal = 1
//        }
        infoPanel.frame = CGRect(x: 0, y: bannerHeight, width: size.width, height: InfoPanel.fixedHeight)
        
        infoPanel.y = -25
        detailView.frame = CGRect(x: 0, y: InfoPanel.fixedHeight, width: size.width, height: scrollView.bounds.height)
    }
    
    /// After all the subviews have been laid out, adjust the content size.
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        scrollView.contentSize.height = infoPanel.bounds.height + detailProvider.contentSize.height
        scrollViewDidScroll(self.scrollView)

    }
    override func viewDidAppear(_ animated: Bool) {
//        scrollViewDidScroll(self.scrollView)
    }
    
    // ========================================
    // MARK: - Setup
    // ========================================
    
    /// Configure the toolbar.
    private func setupToolbar()
    {
        let view = self.view!
        view.addSubview(self.toolbar)
    
        // Toolbar
        toolbar.fadeLength = 20.0
        toolbar.backgroundColor = .clear
        toolbar.titleLabel.textColor = .white
        toolbar.titleLabel.textAlignment = .left
        toolbar.titleLabel.font = UIFont.systemFont(ofSize: 16)
        toolbar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        toolbar.frame = CGRect(x: 0, y: kStatusBarHeight, width: view.width, height: kToolBarHeight)
        
        // Buttons
        let backButton = IconButton()
        backButton.image = #imageLiteral(resourceName: "ic_arrow_back_white")
        backButton.imageView?.tintColor = .white
        backButton.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        toolbar.leftViews = [backButton]
    }
    private func showToolbarTitle() {
        toolbar.titleLabel.textColor = .white
        toolbar.titleLabel.textAlignment = .left
        toolbar.titleLabel.text = detailViewController.title
    }
    
    private func doNotShowToolbarTitle() {
//        if (type(of: self.detailProvider!) == berkeleyMobileiOS.GymClassViewController.self) {
//
//        } else {
//            toolbar.titleLabel.text = ""
//        }
        toolbar.titleLabel.text = ""
        
    }
    /// Configure the banner image and add a gradient.
    private func setupBanner()
    {
        banner.clipsToBounds = true
        banner.layer.addSublayer(bannerGradient)
        
        bannerGradient.colors = [UIColor(white: 0, alpha: 0.75).cgColor, UIColor.clear.cgColor]
    }
    
    /// Configure the `scrollView` and add subviews infoPanel & provier's view.
    private func setupScrollView()
    {
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        scrollView.autoresizesSubviews = false
        
        scrollView.addSubview(infoPanel)
        scrollView.addSubview(detailView)
    }
    
    
    // ========================================
    // MARK: - UIScrollViewDelegate
    // ========================================
    
    /// Perform scroll dependent animations, and adjust the provider's nested offset.
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        guard scrollView === self.scrollView else {
            return
        }
        let inset = scrollView.contentInset.top
        let offset = scrollView.contentOffset.y
        
        let toolbarMaxY = toolbar.frame.maxY
        let infoHeight = InfoPanel.fixedHeight
        
        // If scrollView is pulled down, increase banner height accordingly.
        let pulled = -(inset + offset)
        banner.height = inset + (pulled > 0 ? pulled : 0) + toolbarMaxY
        
        infoPanel.curtainCover = offset
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height == 2436 {
                infoPanel.y = max(-25, offset - infoHeight)
            } else {
                infoPanel.y = max(0, offset - infoHeight)
            }
        }
//        infoPanel.y = max(-25, offset - infoHeight)
        if (offset >= 0) {
            toolbar.reveal = 1
        } else if (offset <= -164) {
            toolbar.reveal = 0
        } else {
            toolbar.reveal = 1  + (offset/164)
        }
        detailView.y = infoPanel.frame.maxY
        detailProvider.contentOffset.y = (offset < infoHeight) ? 0 : (offset - infoHeight);
        
        // Detect end of scrolling (http://stackoverflow.com/a/1857162)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if detailView.y < 75 {
            toolbar.isHidden = false
            toolbar.title = detailViewController.title
            showToolbarTitle()
        } else {
            doNotShowToolbarTitle()
            
        }
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
        let offset = scrollView.contentOffset.y
        
        var lower = -inset
        let upper = InfoPanel.fixedHeight
        
        // If within banner area, snap to top or bottom.
        if (lower ..< upper).contains(offset)
        {
            var finalY = (offset < round(lower/3)) ? lower : upper
            let duration = 1 * Double( abs((finalY - offset) / inset) )
            // Animation duration depends on the the distance.
            UIView.animate(withDuration: duration)
            {
                scrollView.contentOffset = CGPoint(x: 0, y: finalY)
            }
        }
    }
    
    
    // ========================================
    // MARK: - Callback
    // ========================================
    
    func contentSizeDidChange(_ provider: ResourceDetailProvider)
    {
        guard provider === self.detailProvider && provider.resetOffsetOnSizeChanged else
        {
            return
        }
        
        let inset = scrollView.contentInset.top
        let offset = scrollView.contentOffset.y
        let infoHeight = InfoPanel.fixedHeight
        
        
        // New content height is InfoPanel plus internal content height.
        scrollView.contentSize.height = infoHeight + provider.contentSize.height
        
        // Offset is clamped to either inset or InfoHeight.
        scrollView.contentOffset.y = (offset < infoHeight) ? -inset : infoHeight
        scrollViewDidScroll(scrollView)
    }
    
    /// When the back button is tapped, dismiss this view appropriately.
    func backButtonTapped()
    {
        if let vc = self.presentingViewController
        {
            vc.dismiss(animated: true, completion: nil)
        }
        else if let nc = self.navigationController
        {
            nc.popViewController(animated: true)
        }
    }
}
