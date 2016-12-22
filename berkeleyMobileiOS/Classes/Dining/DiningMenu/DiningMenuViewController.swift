
import UIKit

fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)

/**
 * ViewController to display list of menus of one MealType at a certain DiningHall.
 */
class DiningMenuViewController: UIViewController, RequiresData, UITableViewDataSource, UITableViewDelegate
{
    // Data
    private var menu: DiningMenu = []
    
    
    //UI
    @IBOutlet private(set) weak var tableView: UITableView!
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = (type: MealType, menu: DiningMenu)
    
    public func setData(_ data: DataType)
    {
        self.menu = data.menu
        self.pageTabBarItem.title = data.type.name
        self.pageTabBarItem.titleColor = kColorNavy
        self.pageTabBarItem.pulseColor = kColorNavy
    }
    
    
    // ========================================
    // MARK: - UIViewController
    // ========================================
    /**
     * 
     */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isScrollEnabled = false
        
        self.pageTabBarItem.titleColor = kColorNavy
        self.pageTabBarItem.pulseColor = kColorNavy//UIColor.white
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let viewSize = self.view.bounds.size
        self.tableView.frame = CGRect(origin: CGPoint.zero, size: viewSize)
    }
    
    
    // ========================================
    // MARK: - UITableViewDataSource
    // ========================================
    
    // Return the number of menu items.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menu.count
    }
    
    // Get a reuseable cell and set the data.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "DiningItemCell") as! DiningItemCell
        cell.setData(self.menu[indexPath.row])
        
        return cell
    }
}
