
import UIKit

/**
 * ViewController to display list of menus of one MealType at a certain DiningHall.
 */
class DiningMenuListViewController: UIViewController
{
    private var menu: [DiningMenu] = []
    
    
    // MARK: - UIViewController
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    
    // MARK: - Setup
    /**
     *
     */
    public func setData(type: MealType, menu: [DiningMenu])
    {
        let item = self.pageTabBarItem
        item.title = type.name
        item.tintColor = UIColor.white
        
        self.menu = menu
    }
}
