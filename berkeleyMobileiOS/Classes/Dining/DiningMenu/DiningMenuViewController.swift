
import UIKit

/**
 * ViewController to display list of menus of one MealType at a certain DiningHall.
 */
class DiningMenuViewController: UIViewController, RequiresData, UITableViewDataSource, UITableViewDelegate
{
    // Data
    private var menu: DiningMenu = []
    
    
    //UI
    @IBOutlet private(set) weak var tableView: UITableView!
    
    
    // MARK: - UIViewController
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
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
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "DiningItemCell") as! DiningItemCell
        cell.setData(menu[indexPath.row])
        
        return cell
    }
}
