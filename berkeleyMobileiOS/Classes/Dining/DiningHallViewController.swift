
import UIKit
import Material


// Const
fileprivate let kMenuTabSegue = "MenuTabSegue"

fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)


/**
 * ViewController for a specific DiningHall.
 */
class DiningHallViewController: UIViewController
{
    // Data
    var diningHall: DiningHall? = nil
    
    // UI
    @IBOutlet weak var backdrop: UIImageView?
    
    private var menuTabController: PageTabBarController? 
    private var menuTabView: UIView?

    // MARK: - UIViewController
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupMenuTabView()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hideHairline = true
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.hideHairline = false
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let viewSize = self.view.bounds.size
        
        if let menuTabView = self.menuTabView
        {
            var tabViewFrame = CGRect.zero
            tabViewFrame.size = viewSize
            menuTabView.frame = tabViewFrame 
        }
    }
    
    
    // MARK: - Setup
    /**
     *
     */
    private func setupMenuTabView()
    {
        guard 
            let storyboard = self.storyboard,
            let diningHall = self.diningHall 
        else {
            return
        }
    
        // 
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
