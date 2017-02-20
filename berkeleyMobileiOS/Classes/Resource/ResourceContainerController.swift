
import UIKit
import Material

fileprivate let kToolBarHeight: CGFloat = 56.0
fileprivate let kStatusBarHeight: CGFloat = 20.0

fileprivate let kBannerRatio: CGFloat = 16/7




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
        
        toolbar.title = detailViewController.title
        banner.load(url: provider.imageURL)
        
        infoPanel.title = detailViewController.title
        infoPanel.text1 = "1234 Telegraph" //provider.text1
        infoPanel.text2 = "OPEN"//provider.text2
    }
    
    /// Adjust the banner image according to the width, and layout `scrollView` inset below.
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let toolbarBottom = toolbar.frame.maxY
        
        banner.frame = CGRect(x: 0, y: 0, width: view.width, height: round(view.width / kBannerRatio) + toolbarBottom)
        bannerGradient.frame = banner.bounds
        
        scrollView.frame = CGRect(x: 0, y: toolbarBottom, width: view.width, height: view.height - toolbarBottom)
        scrollView.contentInset.top = banner.frame.maxY - toolbarBottom
        scrollView.contentSize = CGSize(width: view.width, height: infoPanel.height + scrollView.height)
        
        infoPanel.frame = CGRect(origin: CGPoint.zero, size: infoPanel.sizeThatFits(view.frame.size))
        detailView.frame = CGRect(x: 0, y: infoPanel.height, width: view.width, height: scrollView.height - infoPanel.height)
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
        toolbar.backgroundColor = .clear
        toolbar.titleLabel.textColor = .white
        toolbar.titleLabel.textAlignment = .left
        toolbar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        toolbar.frame = CGRect(x: 0, y: kStatusBarHeight, width: view.width, height: kToolBarHeight)
        
        toolbar.fadeLength = 20.0
        
        
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
        
        // If scrollView is pulled down, increase banner height accordingly.
        let pulled = -(inset + offset)
        banner.height = inset + (pulled > 0 ? pulled : 0) + toolbarMaxY
        
        // infoPanel & titleLabel reveal.
        infoPanel.curtainCover = offset
        infoPanel.y = max(0, offset - infoPanel.height)
        toolbar.reveal = (offset - toolbar.height) / (infoPanel.height - toolbar.height)
        
        // detailView netsted offset.
        let nestedOffset = max(offset, infoPanel.height)
        detailView.y = nestedOffset
        provider.contentOffset.y = nestedOffset
    }
    
    // ========================================
    // MARK: - Callbacks
    // ========================================
    
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
