
import UIKit
import Material

fileprivate let kToolBarHeight: CGFloat = 56.0
fileprivate let kStatusBarHeight: CGFloat = 20.0

fileprivate let kBannerRatio: CGFloat = 16/7


/**
 * Base class for showing a detailed view of a single `Resource`.
 * Contains and handles all 
 */
class ResourceDetailViewController: UIViewController, RequiresData, UIScrollViewDelegate
{
    // Data
    internal var resource: Resource!
    
    // UI
    internal let toolbar = FadeTitleToolbar()
    
    @IBOutlet internal var banner: UIImageView!
    private let bannerGradient = CAGradientLayer()
    
    @IBOutlet internal var infoPanel: InfoPanel!
    @IBOutlet internal var scrollView: UIScrollView!
    private let scrollGradient = CAGradientLayer()
    
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = Resource
    
    func setData(_ data: DataType)
    {
        resource = data
        
        toolbar.title = resource.name
    }
    
    
    // ========================================
    // MARK: - UIViewController
    // ========================================
    override func awakeFromNib()
    {
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupToolbar()
        setupBanner()
        setupScrollView()
        
        view.clipsToBounds = true
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let toolbarBottom = toolbar.frame.maxY
        
        banner.frame = CGRect(x: 0, y: 0, width: view.width, height: round(view.width / kBannerRatio) + toolbarBottom)
        bannerGradient.frame = banner.bounds
        
        scrollView.frame = CGRect(x: 0, y: toolbarBottom, width: view.width, height: view.height - toolbarBottom)
        scrollView.contentInset.top = banner.frame.maxY - toolbarBottom
        scrollView.contentSize = CGSize(width: view.width, height: infoPanel.height + scrollView.height)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        fillInfoPanel()
    }
    
    
    // ========================================
    // MARK: - Setup
    // ========================================
    internal func setupToolbar()
    {
        let view = self.view!
        view.addSubview(self.toolbar)
    
        // Toolbar
        toolbar.backgroundColor = .clear
        toolbar.titleLabel.textColor = .white
        toolbar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        toolbar.frame = CGRect(x: 0, y: kStatusBarHeight, width: view.width, height: kToolBarHeight)
        
        toolbar.fadeLength = 10.0
        
        
        // Buttons
        let backButton = IconButton()
        backButton.image = #imageLiteral(resourceName: "ic_arrow_back_white")
        backButton.imageView?.tintColor = .white
        backButton.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        toolbar.leftViews = [backButton]
    }
    
    internal func setupBanner()
    {
        banner.load(url: resource.imageURL)
        banner.clipsToBounds = true
        
        bannerGradient.locations = [0, 0.5]
        bannerGradient.colors = [UIColor(white: 0, alpha: 0.75).cgColor, UIColor(white: 1, alpha: 0).cgColor]
        banner.layer.addSublayer(bannerGradient)
    }
    
    internal func setupScrollView()
    {
        scrollView.delegate = self
        scrollView.autoresizesSubviews = false
        
        scrollView.addSubview(infoPanel)
    }
    
    internal func fillInfoPanel()
    {
        infoPanel.title = resource.name
        infoPanel.text1 = nil //address
        infoPanel.text2 = nil //open/close status
    }
    
    
    // ========================================
    // MARK: - UIScrollViewDelegate
    // ========================================
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let inset = scrollView.contentInset.top
        let offset = scrollView.contentOffset.y
        let toolbarMaxY = toolbar.frame.maxY
        
        
        // If scrollView is pulled down, increase banner height accordingly.
        let pulled = -(inset + offset)
        banner.height = inset + (pulled > 0 ? pulled : 0) + toolbarMaxY
        
        
        // InfoPanel
        infoPanel.curtainHeight = offset
        infoPanel.y = max(0, offset - infoPanel.height)
        
        toolbar.reveal = (offset - toolbar.height) / (infoPanel.height - toolbar.height)
    }
    
    // ========================================
    // MARK: - Callbacks
    // ========================================
    
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
