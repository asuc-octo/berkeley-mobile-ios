
import UIKit
import DropDown
import Material
import Firebase
//fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)

fileprivate let kColorNavy = UIColor(red: 0, green: 51/255.0, blue: 102/255.0, alpha: 1)
fileprivate let kColorLightGray = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
fileprivate let kSectionHeaderHeight: CGFloat = 50


/**
 * Displays a single `Resource` type as rows of separate groups/categories.
 * Each row is a horizontally scrolling carousel of tiles representing one `Resource` instance. 
 */
class ResourceGroupViewController: UIViewController, IBInitializable, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    // Data
    var types: [Resource.Type]!

    private var resources = [String : [Resource]]()
    private var selectedResources = [Bool]()
    private var caretImages = [UIImageView]()
    
    var searchableItems: [SearchItem] = []
    var searchResults: [SearchItem] = []
    
    var already_loaded = false
    var loading_label: UILabel?
    
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
        self.selectedResources = []
        for _ in 0..<types.count {
            // All sections are selected in the beginning
            selectedResources.append(true)
        }
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
                
                if (self.resources.count == self.types.count && self.already_loaded != true)
                {
                    self.already_loaded = true
                    self.removeLoadingView()
                    DispatchQueue.main.async { self.tableView.reloadData() }
                }
            }
        }
        
        if UIDevice.current.screenType.rawValue == "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"{
            //edit
            self.tableView.rowHeight = 220
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

    override func viewDidDisappear(_ animated: Bool) {
        removeLoadingView()
    }

    override func viewDidAppear(_ animated: Bool) {
        if (!already_loaded) {
            addLoadingView()
        }
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
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.width)!, height: (self.navigationController?.navigationBar.frame.height)!))
        let image : UIImage = #imageLiteral(resourceName: "bearsmallmed")
        let imageView = UIImageView(frame: CGRect(x: ((self.navigationController?.navigationBar.frame.width)! - 36) / 2, y: 2, width: 36, height: 19))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        
        backView.addSubview(imageView)
        self.navigationItem.titleView = backView
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
                if let _ = segue.destination as? DiningMenuViewController {
                    let menuID = className(DiningMenuViewController.self)
                    let hall = DiningHall(name: diningRes.name, imageLink: nil, shifts: diningRes.meals)

                    let _ = MealType.allValues.map
                        { type in
                    
                            let vc = storyboard!.instantiateViewController(withIdentifier: menuID) as! DiningMenuViewController
                            vc.setData(type: type, shift: hall.meals[type]!)

                            let barItem = vc.pageTabBarItem
                            barItem.titleColor = kColorNavy
                            barItem.pulseColor = kColorNavy

                            barItem.title = type.name
                            barItem.titleLabel?.font = RobotoFont.regular(with: 16)
                        }
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
    }
    
    
    // ========================================
    // MARK: - UITableViewDataSource    
    // ========================================
    
    /// Return the number of groups/categories for Dining.
    func numberOfSections(in tableView: UITableView) -> Int {
        return resources.count
    }
    
    /// Return the number of dining options within the category.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // TODO: temp returning 1, while backend is not up to date.
        let type = types[section]
        if let numberOfDiningOptions = resources[type.typeString]?.count, selectedResources[section] {
            return numberOfDiningOptions
        }
        return 0
    }
    
    /// Pass the DiningGroupCell a name for the category, a list of halls, and a callback handler.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: className(ResourceGroupCell.self)) as! ResourceGroupCell
        let type = types[indexPath.section]
        
        if let diningOptions = resources[type.typeString] {
            cell.setData(diningOptions[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = ResourceGroupSectionHeaderView(frame: .zero)
        headerView.tag = section
        headerView.sectionLabel.text = section == 0 ? "Dining Halls" : "Cafes"
        headerView.backgroundColor = selectedResources[section] ? kColorLightGray : UIColor.white
        headerView.caretImage.image = selectedResources[section] ? UIImage(named: "caretup") : UIImage(named: "caretdown")
        
        // Add a gesture recognizer so the user can click the header
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSelectSectionHeader(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.numberOfTouchesRequired = 1
        headerView.addGestureRecognizer(gestureRecognizer)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kSectionHeaderHeight
    }
    
    // ========================================
    // MARK: - UITableViewDelegate
    // ========================================
    
    /// When a row (not tile) is tapped, present the corresponding `ResourceMapListViewController`.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let type = types[indexPath.section]
        if let diningOptions = resources[type.typeString] {
            let resource = diningOptions[indexPath.row]
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
    }
    
    /// When a section header view is tapped, hide or show the appropriate section
    @objc func didSelectSectionHeader(_ gestureRecognizer: UIGestureRecognizer) {
        if let headerView = gestureRecognizer.view as? ResourceGroupSectionHeaderView {
            selectedResources[headerView.tag] = !selectedResources[headerView.tag]
            
            // Have to check if at least one section is selected.
            var isOneResourceSelected = false
            for value in selectedResources {
                isOneResourceSelected = isOneResourceSelected || value
            }
            
            if isOneResourceSelected {
                tableView.reloadData()
            } else {
                selectedResources[headerView.tag] = !selectedResources[headerView.tag]
            }
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
    
    func removeLoadingView() {
        if let l = self.loading_label {
            l.removeFromSuperview()
        }
    }
    
    func addLoadingView() {
        self.loading_label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 20))
        self.loading_label!.text = "Loading"
        self.loading_label!.textColor = Color.grey.lighten1
        self.loading_label!.font = UIFont.init(name: "System", size: 16)
        self.loading_label!.sizeToFit()
        self.loading_label!.center = view.center
        view.addSubview(self.loading_label!)
    }
    
}

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    enum ScreenType: String {
        case iPhone4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown
    }
    
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX
        default:
            return .unknown
        }
    }
}
