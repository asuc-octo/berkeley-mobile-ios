
import UIKit

/**
 * ViewController to display list of menus of one MealType at a certain DiningHall.
 */
class DiningMenuListViewController: UIViewController, UITableViewDataSource
{
    // Data
    private var menu: [DiningMenu] = []
    
    
    //UI
    @IBOutlet weak var tableView: UITableView?
    
    
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
    
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return UITableViewCell()
    }
}
