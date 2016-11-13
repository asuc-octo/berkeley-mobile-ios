
import UIKit
import Material


fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)

/**
 * ViewController for a specific DiningHall.
 */
class DiningHallViewController: UIViewController
{
    // Data
    var diningHall: DiningHall? = nil
    
    // UI
    var backdrop: UIImageView = UIImageView()
    
    var tabController: PageTabBarController? = nil


    // MARK: - UIViewController
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupTabs()
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
        
        if let tabView = self.tabController?.view
        {
            var tabFrame = CGRect.zero
            tabFrame.size = viewSize
            tabView.frame = tabFrame 
        }
    }
    
    
    // MARK: - Setup
    func setupTabs()
    {
        let breakfastVC = DiningMenuListViewController(type: MealType.Breakfast, menu: diningHall!.breakfastMenu)
        let lunchVC     = DiningMenuListViewController(type: MealType.Lunch,     menu: diningHall!.lunchMenu)
        let dinnerVC    = DiningMenuListViewController(type: MealType.Dinner,    menu: diningHall!.dinnerMenu)
        let lateNightVC = DiningMenuListViewController(type: MealType.LateNight, menu: diningHall!.lateNightMenu)
        
        self.tabController = PageTabBarController(viewControllers: [breakfastVC, lunchVC, dinnerVC, lateNightVC], selectedIndex: 0)
        guard let tabController = self.tabController else {
            return
        }
        
        self.addChildViewController(tabController)
        self.view.addSubview(tabController.view!)
        tabController.pageTabBarAlignment = .top
        
        let tabbar = tabController.pageTabBar
        tabbar.backgroundColor = kColorNavy
        tabbar.lineColor = UIColor.white
        tabbar.lineAlignment = .bottom
        tabbar.divider.thickness = 0
    }
}
