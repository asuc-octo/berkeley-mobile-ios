
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
    private weak var navbar: UINavigationBar?
    private var pseudoNavbar: UIView!
    
    @IBOutlet private weak var tableView: UITableView!
    private var activityIndicator: UIActivityIndicatorView!
    

    // ========================================
    // MARK: - UIViewController
    // ========================================
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        // TODO: this should be set in LaunchViewController.
        let item = self.navigationController?.pageTabBarItem
        item?.image = UIImage(named: "icon_dining")?.withRenderingMode(.alwaysTemplate)
        item?.imageView?.contentMode = .scaleAspectFit
    }
    
    /**
     * Called after view is loaded.
     * Configure navbar, add the tableView, and load DiningHall data.
     */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setupActivityIndicator()
        
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
        
        self.navbar?.hideHairline = true
        self.navbar?.setTransparent(true)
        setStatusBarStyle(self.preferredStatusBarStyle)
        
        if let nc = self.navigationController 
        {
            ConvenienceMethods.setCurrentTabStyle(pageTabBarVC: pageTabBarController!, ForSelectedViewController: nc)
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let view = self.view!
        
        let navbarMaxY = self.navbar?.frame.maxY ?? 0
        self.pseudoNavbar.frame = CGRect(x: 0, y: -navbarMaxY, width: view.width, height: navbarMaxY)
    }
    
    
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
        // Insert a pseudo-background
        self.pseudoNavbar = UIView()
        self.pseudoNavbar.backgroundColor = kColorNavy
        self.view!.addSubview(self.pseudoNavbar)
        
    
        // Configure the navigationBar.
        self.navbar = self.navigationController?.navigationBar
        guard let navbar = self.navbar else {
            return
        } 
        
        // White content
        navbar.tintColor = .white
        navbar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
    }
    
    /// Configure and add the ActivityIndicator.
    private func setupActivityIndicator()
    {
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = self.view!.center
        self.activityIndicator.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        self.view.addSubview(self.activityIndicator)
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
