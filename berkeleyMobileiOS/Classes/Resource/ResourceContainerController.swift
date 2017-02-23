
import UIKit
import Material

fileprivate let kToolBarHeight: CGFloat = 56.0
fileprivate let kStatusBarHeight: CGFloat = 20.0

fileprivate let kBannerRatio: CGFloat = 16/7
fileprivate let kAnimationDuration: TimeInterval = 0.25



/**
 * 
 */
class ResourceContainerController: UIViewController, RequiresData, UIScrollViewDelegate
{    
    // UI
    private let toolbar = FadeTitleToolbar()
    
    @IBOutlet private var banner: UIImageView!
    private let bannerGradient = CAGradientLayer()

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var infoPanel: InfoPanel!
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = ResourceDetailProvider
    
    func setData(_ data: ResourceDetailProvider)
    {
        provider = data
        addChildViewController(detailViewController)
    }
    
    
    // ========================================
    // MARK: - ResourceDetail
    // ========================================
    private var provider: ResourceDetailProvider!
    
    private var detailViewController: UIViewController 
    { 
        return provider.viewController 
    }
    
    private var detailView: UIView
    { 
        return provider.viewController.view
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
        
        
        banner.load(url: provider.imageURL)
        infoPanel.title = detailViewController.title
        infoPanel.text1 = "1234 Telegraph" //provider.text1
        infoPanel.text2 = "OPEN"//provider.text2
        
        toolbar.title = detailViewController.title
        toolbar.rightViews = provider.buttons
        toolbar.rightViews.forEach
        {
            $0.tintColor = .white
            $0.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        }
        
        provider.contentSizeChangeHandler = contentSizeDidChange
    }
    
    /// Adjust the banner image according to the width, and layout `scrollView` inset below.
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let toolbarBottom = toolbar.frame.maxY
        let infoHeight = InfoPanel.fixedHeight
        
        banner.frame = CGRect(x: 0, y: 0, width: view.width, height: round(view.width / kBannerRatio) + toolbarBottom)
        bannerGradient.frame = banner.bounds
        
        scrollView.frame = CGRect(x: 0, y: toolbarBottom, width: view.width, height: view.height - toolbarBottom)
        scrollView.contentInset.top = banner.frame.maxY - toolbarBottom
        contentSizeDidChange(provider)
        
        infoPanel.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: infoHeight)
        detailView.frame = CGRect(x: 0, y: infoHeight, width: view.width, height: scrollView.height)
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
        let inset = scrollView.contentInset.top
        let offset = scrollView.contentOffset.y
        
        let toolbarMaxY = toolbar.frame.maxY
        let infoHeight = infoPanel.height
        
        // If scrollView is pulled down, increase banner height accordingly.
        let pulled = -(inset + offset)
        banner.height = inset + (pulled > 0 ? pulled : 0) + toolbarMaxY
        
        // infoPanel & titleLabel reveal.
        infoPanel.curtainCover = offset
        infoPanel.y = max(0, offset - infoHeight)
        toolbar.reveal = (offset - toolbar.height) / (infoHeight - toolbar.height)
        
        // detailView netsted offset.
        detailView.y = infoPanel.frame.maxY
        provider.contentOffset.y = (offset < infoHeight) ? 0 : (offset - infoHeight);
        
        
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
        let offset = scrollView.contentOffset.y
        
        let lower = -inset
        let upper = InfoPanel.fixedHeight
        
        // If within banner area, snap to top or bottom.
        if (lower ..< upper).contains(offset)
        {
            let finalY = (offset < round(lower/3)) ? lower : upper
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
        guard self.provider === provider else
        {
            return
        }
        
        let inset = scrollView.contentInset.top
        let offset = scrollView.contentOffset.y
        let infoHeight = InfoPanel.fixedHeight
        
        
        // New content height is InfoPanel plus internal content height.
        let contentHeight = infoHeight + provider.contentSize.height
        
        // Final offset is clamped to either inset or InfoHeight.
        let finalOffset = (offset < infoHeight) ? -inset : infoHeight;
        
        scrollView.contentSize = CGSize(width: view.width, height: contentHeight)
        scrollView.contentOffset = CGPoint(x: 0, y: finalOffset)
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
