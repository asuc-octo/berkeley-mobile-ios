
import UIKit



class DiningMenuListViewController: UIViewController
{
    var menu: [DiningMenu] = []
    
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
    }
    
    
    /**
     *
     */
    private func setMenu(_ menu: [DiningMenu])
    {
        
    }
}
