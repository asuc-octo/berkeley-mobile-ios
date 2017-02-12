
import UIKit

private let DiningHallSegue = "DiningHallSegue"

fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)


/**
 * `ResourceGroupViewController` displays a table of a single `Resource` type separate groups.
 * Each cell contains a side-scrolling carousel of `Resources` as tiles.  
 */
class ResourceGroupViewController: UIViewController, RequiresData, UITableViewDelegate, UITableViewDataSource
{
    // Data
    var resourceType: ResourceType!
    var resources: [Resource] = []
    
    
    // UI
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private weak var navbar: UINavigationBar?
    private var pseudoNavbar: UIView!
    
    @IBOutlet private weak var tableView: UITableView!
    private var activityIndicator: UIActivityIndicatorView!
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = ResourceType
    
    func setData(_ type: DataType)
    {
        self.resourceType = type
        
        self.title = type.rawValue
    }
    
    
    // ========================================
    // MARK: - UIViewController
    // ========================================
    /**
     * Setup any remaining UI components not done in IB,
     * and fetch resources to display.
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
        
        self.resourceType.dataSourceType.fetchResources
        { (_ resources: [Resource]?) in
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
            if resources.isNil
            {
                // Error
                return
            }
            
            self.resources = resources!
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    /// Configure statusBar, navigationBar, and highlight the tab icon. 
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);
        
        self.navbar?.hideHairline = true
        self.navbar?.setTransparent(true)
        setStatusBarStyle(self.preferredStatusBarStyle)
        
        if let navController = self.navigationController 
        {
            ConvenienceMethods.setCurrentTabStyle(pageTabBarVC: pageTabBarController!, ForSelectedViewController: navController)
        }
    }
    
    /// Place the pseudoNavbar backdrop behind the navbar.
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
     * 
     * - Attention: Transparent UINavigationBar and pseudoNavbar backdrop is a temporary solution.
     *      NavigationController and bar should be reworked into a custom class.
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
        let data = (self.resourceType.rawValue, self.resources, Optional(didSelectResource))
        
        let cell = tableView.dequeueReusableCell(withIdentifier: className(ResourceGroupCell.self)) as! ResourceGroupCell
        cell.setData(data)
        return cell
    }
    
    
    // ========================================
    // MARK: - UITableViewDelegate
    // ========================================
    /**
     * Called when an entire category row is tapped.
     * Present the corresponding list of resources.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    
    /**
     * Called by ResourceGroupCell when a ResourceTile is tapped.
     * Presen the corresponding detail view of the resource.
     */
    func didSelectResource(_ resource: Resource)
    {
        
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
