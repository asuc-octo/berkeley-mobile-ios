
import UIKit
import DropDown
import Material
import Firebase
fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)


/**
 * Displays a single `Resource` type as rows of separate groups/categories.
 * Each row is a horizontally scrolling carousel of tiles representing one `Resource` instance. 
 */
class ResourceGroupViewController: UIViewController, IBInitializable, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    // Data
//    private var types: [Resource.Type]!
    var types: [Resource.Type]!

    private var resources = [String : [Resource]]()
    
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
    
    var diningRes: DiningHall!
    
    
    // ========================================
    // MARK: - IBInitializable
    // ========================================
    typealias IBComponent = ResourceGroupViewController
    
    static var componentID: String { return className(IBComponent.self) }
    
    static func fromIB() -> IBComponent 
    {
        return UIStoryboard.resource.instantiateViewController(withIdentifier: self.componentID) as! IBComponent
    }
    
    func setGroup(_ group: ResourceGroup)
    {
        guard viewIfLoaded == nil, types == nil else {
            return
        }
        
        types = group.types
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
        
        types.forEach 
        { type in

            type.dataSource?.fetchResources
            { list in
                
                DispatchQueue.main.async { self.activityIndicator.stopAnimating() }
                
                guard let nonEmptyList = list else
                {
                    // Error
                    return print()
                }
                
                self.resources[type.typeString] = nonEmptyList
                
                if self.resources.count == self.types.count
                {
                    DispatchQueue.main.async { self.tableView.reloadData() }
                }
            }
        }
    }
    
    /// Configure statusBar, navigationBar, and highlight the tab icon. 
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);
        for some_type in self.types! {
            if (some_type == berkeleyMobileiOS.Library.self) {
                Analytics.logEvent("opened_library_screen", parameters: nil)

            } else if (some_type == berkeleyMobileiOS.CampusResource.self) {
                Analytics.logEvent("opened_resource_screen", parameters: nil)
            } else if (some_type == berkeleyMobileiOS.DiningHall.self) {
                Analytics.logEvent("opened_food_screen", parameters: nil)

            } else if (some_type == berkeleyMobileiOS.Gym.self) {
                Analytics.logEvent("opened_gym_screen", parameters: nil)

            } else if (some_type == berkeleyMobileiOS.GymClass.self) {
                Analytics.logEvent("opened_gym_class_screen", parameters: nil)
            } else {
                print("Error")
            }
        }
        self.navbar?.hideHairline = true
        self.navbar?.setTransparent(true)
        setStatusBarStyle(self.preferredStatusBarStyle)
        for vc in (self.pageTabBarController?.viewControllers)! {
            if (type(of: vc) == BearTransitNavigationController.self) {
                vc.pageTabBarItem.image = #imageLiteral(resourceName: "beartransit").withRenderingMode(.alwaysTemplate)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {

    }
    /// Place the pseudoNavbar backdrop behind the navbar.
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let view = self.view!
        
        let navbarMaxY = self.navbar?.frame.maxY ?? 0
        let eliminateSpace: CGFloat = 12
        self.pseudoNavbar.frame = CGRect(x: 0, y: -navbarMaxY - eliminateSpace, width: view.width, height: navbarMaxY + 10)
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
        let image : UIImage = #imageLiteral(resourceName: "bearsmallmed")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.navigationItem.titleView = imageView
//        let iv = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 24, height: 24))
//        iv.image = #imageLiteral(resourceName: "bear")
//        self.navigationItem.titleView = iv
//        let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
//        textFieldInsideUISearchBar?.borderStyle = .none
//        textFieldInsideUISearchBar?.backgroundColor = kColorNavy
//        textFieldInsideUISearchBar?.textColor = UIColor.white
        
        
//        searchBar.delegate = self
////        searchDropDown.frame = CGRect(x: 0, y: -20, width: searchDropDown.frame.width, height: searchDropDown.frame.height)
//        searchDropDown.anchorView = self.navigationItem.titleView
//        searchDropDown.bottomOffset = CGPoint(x: 0, y: 50)
//        // searchDropDown.dismissMode = .manual
//        searchDropDown.selectionAction = selectedRow
//        searchDropDown.cancelAction = cancelDropDown
    }
    
    func selectedRow(index: Int, name: String) -> Void
    {
        searchDropDown.hide()
        searchBar.resignFirstResponder()
        let selected = searchResults[index]
        selected.detailedData
        { (resource: Resource?) in
            
            guard let res = resource else {
                return
            }
            
            let ref = type(of: res).typeString + "DetailSegue"
            if type(of: res).typeString == "DiningHall" {
                self.diningRes = res as? DiningHall
            }
            self.performSegue(withIdentifier: ref, sender: res)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "DiningHallDetailSegue" {
                if let dest = segue.destination as? DiningMenuViewController {
                    let menuID = className(DiningMenuViewController.self)
                    let hall = DiningHall(name: diningRes.name, imageLink: nil, shifts: diningRes.meals)

                    let menuControllers = MealType.allValues.map
                        { type in
                    
                            let vc = storyboard!.instantiateViewController(withIdentifier: menuID) as! DiningMenuViewController
                            vc.setData(type: type, shift: hall.meals[type]!)

                            let barItem = vc.pageTabBarItem
                            barItem.titleColor = kColorNavy
                            barItem.pulseColor = kColorNavy//UIColor.white

                            barItem.title = type.name
                            barItem.titleLabel?.font = RobotoFont.regular(with: 16)
                        }
                    }
            }
            else if identifier == "LibraryDetailSegue" {
//                if let dest = segue.destination as? SettingsViewController {
//                    // do stuff in the settingsVC before it loads
//                }
            }
            else if identifier == "GymDetailSegue" {
                if segue.destination is GymDetailViewController {
//                    let gym = Gym(name: , address: String, imageLink: String?, openingTimeToday: Date?, closingTimeToday: Date?)
                }
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
        let type = types[indexPath.row]
        let data = (type.displayName(pluralized: true), resources[type.typeString]!, Optional(didSelectResource))
        
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
        guard let detailProvider = type(of: resource).detailProvider?.newInstance() else 
        { 
            return 
        }
        detailProvider.resource = resource
        
        let container = ResourceContainerController.fromIB()
        container.detailProvider = detailProvider
        
        container.modalPresentationStyle = .overFullScreen
        present(container, animated: true, completion: nil)
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
