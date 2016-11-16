
import UIKit

/**
 * ViewController to display list of menus of one MealType at a certain DiningHall.
 */
class DiningMenuViewController: UIViewController, RequiresData, UITableViewDataSource
{
    // Data
    private var menu: DiningMenu = []
    
    
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
    
    
    // MARK: - RequestsData
    typealias DataType = (type: MealType, menu: DiningMenu)
    
    public func setData(_ data: DataType)
    {
        let item = self.pageTabBarItem
        item.title = data.type.name
        item.tintColor = UIColor.white
        
        self.menu = data.menu
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
        let cell = tableView.dequeueReusableCell(withIdentifier: className(DiningItemCell.self)) as! DiningItemCell
        cell.setData(menu[indexPath.row])
        
        return UITableViewCell()
    }
}
