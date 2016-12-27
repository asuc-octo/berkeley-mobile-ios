
import UIKit

private let DiningGroupCellID = "DiningGroupCell"
private let DiningHallSegue = "DiningHallSegue"

fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)


/**
 * ViewController that shows the list of all DiningHalls.
 */
class DiningGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    // Data
    var halls: [DiningHall] = []

    // UI
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    @IBOutlet private weak var tableView: UITableView!
    var activityIndicator: UIActivityIndicatorView!
    
    
    // ========================================
    // MARK: - UIViewController
    // ========================================
    /**
     * Called after view is loaded.
     * Configure navbar, add the tableView, and load DiningHall data.
     */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let screen = UIScreen.main.bounds
        let screenSize = screen.size
        
        // Navbar settings.
        let navbar = self.navigationController!.navigationBar
        self.navigationController!.statusBarStyle = .lightContent
        navbar.barStyle = .black
        navbar.isTranslucent = false
        navbar.tintColor = UIColor.white
        navbar.barTintColor = kColorNavy
        navbar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
        
        // Add tableView.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        
        // Activity Indicator
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.activityIndicator.center = CGPoint(x: screenSize.width/2, y: screenSize.height * 1/3)
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
        
        
        // Fetch data.
        self.activityIndicator.startAnimating()
        DiningDataSource.fetchDiningHalls()
        { (_ halls: [DiningHall]?) in
        
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        
            if halls.isNil
            {
                // Show some error screen.
                print("[ERROR @ DiningHallTableViewController] failed to fetch DiningHalls")
                return
            }
            
            self.halls = halls!
            
            // Reload in main thread.
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);
        setStatusBarStyle(self.preferredStatusBarStyle)
    }
    
    
    // ========================================
    // MARK: - UITableViewDataSource    
    // ========================================
    
    /// Return the number of groups/categories for Dining.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // TODO: temp returning 1, while backend is not up to date.
        return 1
    }
    
    /// 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // TODO: currently only shows dining halls on campus.
        let data = ("Dining Halls", halls, Optional(didSelectDiningHall))
        
        let cell = tableView.dequeueReusableCell(withIdentifier: DiningGroupCellID) as! DiningGroupCell
        cell.setData(data)
        return cell
    }
    
    /// Called when LocationTitle within DiningGroupCell is selected (tapped).
    func didSelectDiningHall(_ hall: DiningHall)
    {
        self.performSegue(withIdentifier: DiningHallSegue, sender: hall)
    }
    
    
    // ========================================
    // MARK: - Navigation
    // ========================================

    /// Pass the DiningHall data to the DiningHallVC.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == DiningHallSegue,
        let diningHall   = sender as? DiningHall,
        let diningHallVC = segue.destination as? DiningHallViewController
        {
            diningHallVC.setData(diningHall)
        }
    }
}
