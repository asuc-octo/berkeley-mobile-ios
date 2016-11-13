
import UIKit

class DiningMenuListViewController: UIViewController
{

    var menu: [DiningMenu] = []

    /**
     * 
     */
    init(type: MealType, menu: [DiningMenu] = [])
    {        
        super.init(nibName: nil, bundle: nil)
        
        self.setMenu(menu)
        pageTabBarItem.title = type.rawValue
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    
    /**
     *
     */
    func setMenu(_ menu: [DiningMenu])
    {
        
    }
}
