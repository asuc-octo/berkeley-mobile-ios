
import UIKit

private let DiningGroupCellID = "DiningGroupCell"
private let DiningHallSegue = "DiningHallSegue"

fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)


/**
 * Presents all DiningHalls with each category as a row of carousel tiles. 
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
    // MARK: - Setup
    // ========================================
    
    /**
     * Makes the original UINavigationBar clear and inserts another view with solid color.
     * This is to prevent strage transitions when pushing/popping ViewControllers with clear navbar.
     * TODO: find a solution for  
     */
    private func setupNavigationBar()
    {
        guard 
            let navbar = self.navigationController?.navigationBar 
        else
        { return }
        
        // White content
        navbar.tintColor = .white
        navbar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
        
        // Clear background
        navbar.setBackgroundImage(UIImage(), for: .default)
        navbar.shadowImage = UIImage()
        navbar.isTranslucent = true
        
        // Insert a pseudo-background
        let height = navbar.height + 20
        let bgView = UIView(frame: CGRect(x: 0, y: -height, width: navbar.width, height: height))
        bgView.backgroundColor = kColorNavy
        self.view!.addSubview(bgView)
    }
    
    /// Configure and add the ActivityIndicator.
    private func setupActivityIndicator()
    {
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
    }
    
    
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
        
        setupNavigationBar()
        setupActivityIndicator()
        
        // Connect tableView and load data
        self.tableView.delegate = self
        self.tableView.dataSource = self
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
    
    /// Pass the DiningGroupCell a name for the category, a list of halls, and a callback handler.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // TODO: currently only shows dining halls on campus.
        let data = ("Dining Halls", halls, Optional(didSelectDiningHall))
        
        let cell = tableView.dequeueReusableCell(withIdentifier: DiningGroupCellID) as! DiningGroupCell
        cell.setData(data)
        return cell
    }
    
    // ========================================
    // MARK: - UITableViewDelegate
    // ========================================
    
    /**
     * Called by DiningGroupCell when a DiningHall (LocationTile) is tapped.
     * Perform the DiningHallSegue. 
     */
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
