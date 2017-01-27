
import UIKit

fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)

/**
 * ViewController to display list of menus of one MealType at a certain DiningHall.
 */
class DiningMenuViewController: UIViewController, RequiresData, DelegatesScroll, UITableViewDataSource, UITableViewDelegate
{
    // Data
    private var shift: MealShift!
    private var favoritedItems: [String]!
    
    
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
    }
    
    
    // ========================================
    // MARK: - UIViewController
    // ========================================
    
    /// Configure the pageTabItem. 
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.pageTabBarItem.titleColor = kColorNavy
        self.pageTabBarItem.pulseColor = kColorNavy//UIColor.white
    }
    
    /// Configure the tableView and open hours label. 
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view!.clipsToBounds = true
        self.view!.sendSubview(toBack: self.tableView)
        
        // Configure tableView.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isScrollEnabled = false
        
        
        // Display the open hours.
        let hoursLayer = self.hoursView.layer
        hoursLayer.shadowRadius = 2
        hoursLayer.shadowOpacity = 0.2
        hoursLayer.shadowColor = UIColor.clear.cgColor
        hoursLayer.shadowOffset = CGSize(width: 0, height: 2)
        
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
    
    /// Return the number of menu items.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.shift.menu.count
    }
    
    /// Get a reuseable cell and set the data.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let item = self.shift.menu[indexPath.row]
        let favorited = FavoriteStore.sharedInstance.contains(type: DiningItem.self, name: item.name)
    
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "DiningItemCell") as! DiningItemCell
        cell.setData( (item, favorited) )
        
        return cell
    }
    
    
    // ========================================
    // MARK: - DelegatesScroll
    // ========================================
    
    /// Return the current size of the tableView.
    var contentSize: CGSize
    {
        get { return self.tableView.contentSize }
    }
    
    /// Return the current offset or pass the set offset action.
    var contentOffset: CGPoint
    {
        get { return self.tableView.contentOffset }
        set { self.tableView.contentOffset = newValue }
    }
    
    /// Relay the set action.
    func setContentOffset(_ offset: CGPoint, animated: Bool)
    {
        self.tableView.setContentOffset(offset, animated: animated)
    }
    
    
    // ========================================
    // MARK: - UIScrollViewDelegate
    // ========================================
    
    /// When scrolled down, apply shadow to hoursView.
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let offset = scrollView.contentOffset.y
        self.showScrollShadow = offset > 0
    }
    
    
    // ========================================
    // MARK: - Private
    // ========================================
    
    /// Sets MenuTabBar's shadow to black to show, and clear to hide.
    private var showScrollShadow: Bool = false
    {
        didSet 
        {
            self.hoursView.layer.shadowColor = (showScrollShadow ? UIColor.black : UIColor.clear).cgColor
        }
    }
}
