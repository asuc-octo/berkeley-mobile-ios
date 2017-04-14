
import UIKit
import DropDown

fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)


/**
 * Displays a single `Resource` type as rows of separate groups/categories.
 * Each row is a horizontally scrolling carousel of tiles representing one `Resource` instance. 
 */
class ResourceGroupViewController: UIViewController, IBInitializable, RequiresData, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    // Data
    var resourceType: ResourceType!
    var resources: [ResourceType: [Resource]] = [:]
//    var resources: [Resource] = []
    var searchableItems: [SearchItem] = []
    var searchResults: [SearchItem] = []
    
    
    // UI
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private weak var navbar: UINavigationBar?
    private var pseudoNavbar: UIView!
    private var searchBar = UISearchBar()
    let searchDropDown = DropDown()
    
    @IBOutlet private weak var tableView: UITableView!
    private var activityIndicator: UIActivityIndicatorView!
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias IBComponent = ResourceGroupViewController
    
    static var componentID: String { return className(IBComponent.self) }
    
    static func fromIB() -> IBComponent 
    {
        return UIStoryboard.main.instantiateViewController(withIdentifier: self.componentID) as! IBComponent
    }
    
    
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
        self.setupSearchBar()
        self.setupActivityIndicator()
        
        // Connect tableView and load data
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.activityIndicator.startAnimating()
        
        for type in ResourceType.connections[self.resourceType]! {
            
            type.dataSourceType.fetchResources
                { (_ resources: [Resource]?) in
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                    
                    if resources.isNil
                    {
                        // Error
                        return
                    }
                    
                    if ((resources?.count)! > 0) {
                        self.resources[type] = resources
                    }
                    
                    DispatchQueue.main.async {
                        if (self.resources.count == ResourceType.connections[self.resourceType]!.count) {
                            self.tableView.reloadData()
                        }
                        
                    }
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
    
    // ========================================
    // MARK: - UISearchBar Setup
    // ========================================
    /**
     *
     */
    
    private func setupSearchBar()
    {
        // Search bar
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchDropDown.anchorView = self.navigationItem.titleView
        searchDropDown.bottomOffset = CGPoint(x: 0, y: 50)
        // searchDropDown.dismissMode = .manual
        searchDropDown.selectionAction = selectedRowFromSearch
        searchDropDown.cancelAction = cancelDropDown
    }
    
    func selectedRowFromSearch(index: Int, name: String) -> Void {
        searchDropDown.hide()
        searchBar.resignFirstResponder()
        let selected = searchResults[index]
        selected.detailedData { (_ resource: Resource?) in
            guard let res = resource else {
                return
            }
            let ref = res.type.rawValue + "DetailSegue"
 
            if let gymClass = res as? GymClass {
                if (self.resources[ResourceType.GymClassCategory]?.count)! > 0 {
                    let gymClassCategory = GymClassCategory(name: gymClass.class_type!, imageLink: "dsff")
                    self.performSegue(withIdentifier: ref, sender: gymClassCategory)
                }
            }
            else {
                self.performSegue(withIdentifier: ref, sender: res)
            }
 
        }
    }
    
    func cancelDropDown() -> Void {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
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
        return self.resources.count
    }
    
    /// Pass the DiningGroupCell a name for the category, a list of halls, and a callback handler.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let type = ResourceType.connections[self.resourceType]![indexPath.row]
        let res = self.resources[type]!
        
        let data = (type.displayName, res, Optional(didSelectResource))
        
        let cell = tableView.dequeueReusableCell(withIdentifier: className(ResourceGroupCell.self)) as! ResourceGroupCell
        cell.setData(data)
        return cell
    }
    
    
    // ========================================
    // MARK: - UITableViewDelegate
    // ========================================
    
    /// When a row (not tile) is tapped, present the corresponding `ResourceMapListViewController`.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // TODO: MapList disabled temporarily.
    }
    
    /// When a tile is tapped, present the corresponding `ResourceDetailViewController`.
    func didSelectResource(_ resource: Resource)
    {
//        let ref = self.resourceType.rawValue + "DetailSegue"
//        self.performSegue(withIdentifier: ref, sender: resource)

        
        if let thisResource = resource as? Library {
            print("this is a library")
            let detailID = className(LibraryDetailViewController.self)
            let detail = self.storyboard?.instantiateViewController(withIdentifier: detailID) as! LibraryDetailViewController
            detail.setData(thisResource)
            
            let containerID = className(ResourceContainerController.self)
            let container = storyboard!.instantiateViewController(withIdentifier: containerID) as! ResourceContainerController
            container.setData(detail)
            present(container, animated: true, completion: nil)
            
        } else if let thisResource = resource as? DiningHall {
            print("this is a dining hall")
            let detailID = className(DiningHallViewController.self)
            let detail = UIStoryboard(name: "Dining", bundle: nil).instantiateViewController(withIdentifier: detailID) as! DiningHallViewController
            detail.setData(thisResource)
            
            let containerID = className(ResourceContainerController.self)
            let container = storyboard!.instantiateViewController(withIdentifier: containerID) as! ResourceContainerController
            container.setData(detail)
             present(container, animated: true, completion: nil)
        } else if let thisResource = resource as? Gym {
            print("this is a gym")
            let detailID = className(GymDetailViewController.self)
           let detail = self.storyboard?.instantiateViewController(withIdentifier: detailID) as! GymDetailViewController
            detail.setData(thisResource)
            
            let containerID = className(ResourceContainerController.self)
            let container = storyboard!.instantiateViewController(withIdentifier: containerID) as! ResourceContainerController
            container.setData(detail)
            present(container, animated: true, completion: nil)
        } else {
            return
        }
        
        
        
        
    
        
       
    }

    
    // ========================================
    // MARK: - Navigation
    // ========================================
    /**
     * Cast the Resource to the corresponding type for each segue.
     * 
     * TODO: Create a parent Resource(Detail)ViewController to clean this junk up.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destination = segue.destination
        
        if let vc = destination as? GymsMapListViewController
        {
            vc.gyms = self.resources[ResourceType.Gym] as! [Gym]
        } 
        else if let vc = destination as? GymDetailViewController
        {
            vc.gym = sender as? Gym
        }
        else if let vc = destination as? LibraryMapViewController
        {
            vc.libraries = self.resources[ResourceType.Library] as! [Library]
        }
        else if let vc = destination as? LibraryDetailViewController
        {
            vc.library = sender as? Library
        }
        else if let vc = destination as? GymClassViewController
        {
            vc.classType = sender as? GymClassCategory
        }
        else if let vc = destination as? GymClassDetailViewController
        {
            vc.classCategories = self.resources[ResourceType.GymClassCategory] as? [GymClassCategory]
        }
        else if let vc = destination as? CampusResourceMapListViewController
        {
            vc.campusResources = self.resources[ResourceType.CampusResource] as? [CampusResource]
        }
        else if let vc = destination as? CampusResourceDetailViewController
        {
            vc.campusResource = sender as? CampusResource
        }
    }
    
    // ========================================
    // MARK: - UISearchDelegate
    // ========================================
    /**
     * TODO: Change the dismiss behavior.
     */
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        filterList(searchBar.text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterList(searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        if searchableItems.count == 0 {
            SearchDataSource.fetchSearchItems
                { (_ searchItems: [SearchItem]?) in
                    self.searchableItems = searchItems!.filter { item in item.category != "Sports Schedule"}
                    self.searchableItems = self.searchableItems.filterDuplicates { $0.name == $1.name }
                    self.searchResults = self.searchableItems
                    self.searchDropDown.dataSource = self.searchResults.map { item in item.name }
                    self.searchDropDown.show()
            }
        }
        else {
            self.searchDropDown.dataSource = self.searchResults.map { item in item.name }
            self.searchDropDown.show()
            
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchDropDown.hide()
        searchBar.showsCancelButton = false
    }
    
    func filterList(_ searchText: String?) {
        if searchText == nil || searchText! == "" {
            searchDropDown.dataSource = searchableItems.map { item in item.name }
        }
        else {
            let keyword = searchText!.lowercased()
            searchResults = searchableItems.filter({ item in (item.name.lowercased().contains(keyword)) })
            searchDropDown.dataSource = searchResults.map { item in item.name }
        }
    }
}
