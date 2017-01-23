
import UIKit

fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)

/**
 * ViewController to display list of menus of one MealType at a certain DiningHall.
 */
class DiningMenuViewController: UIViewController, RequiresData, UITableViewDataSource, UITableViewDelegate
{
    // Data
    private var shift: MealShift!
    
    
    //UI
    @IBOutlet private weak var hoursView: UIView!
    @IBOutlet private weak var hoursLabel: UILabel!
    
    @IBOutlet private(set) weak var tableView: UITableView!
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = (type: MealType, shift: MealShift)
    
    public func setData(_ data: DataType)
    {
        self.shift = data.shift
        
        self.pageTabBarItem.title = data.type.name
        self.pageTabBarItem.titleColor = kColorNavy
        self.pageTabBarItem.pulseColor = kColorNavy//UIColor.white
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
        
        // Display the open hours.
        if self.shift.open.isNil || self.shift.close.isNil {
            self.hoursLabel.text = "CLOSED"
            return
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let open  = formatter.string(from: self.shift.open!)
        let close = formatter.string(from: self.shift.close!)
        self.hoursLabel.text = open + " ~ " + close
    }
    
    
    // ========================================
    // MARK: - UITableViewDataSource
    // ========================================
    
    // Return the number of menu items.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.shift.menu.count
    }
    
    // Get a reuseable cell and set the data.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "DiningItemCell") as! DiningItemCell
        cell.setData( self.shift.menu[indexPath.row] )
        
        return cell
    }
}
