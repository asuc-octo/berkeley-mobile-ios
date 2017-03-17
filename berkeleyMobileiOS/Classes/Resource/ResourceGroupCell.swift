
import UIKit
import Material

fileprivate let kResourceTileID = "ResourceTile"

protocol ShowSortMenu : class {
    func presentSortMenu(controller: ListMenuController) -> Void;
    func dismissSortMenu() -> Void;
}

/**
 * 
 */
class ResourceGroupCell: UITableViewCell, RequiresData, UICollectionViewDataSource, UICollectionViewDelegate
{
    typealias SelectionHandler = (Resource) -> Void
    
    // Data
    private var resources: [Resource]!
    private var selectionHandler: SelectionHandler?

    // UI
    @IBOutlet private weak var groupLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private let sortMenuController = ListMenuController()
    var delegate: ShowSortMenu?
    
    
    /// Configure the collectionView.
    override func awakeFromNib()
    {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        
        setupSortMenu()
    }
    
    /// Intialize and configure the modal `ListMenuController` for sorting options.
    private func setupSortMenu()
    {
        let menu = sortMenuController
        menu.message = "Sort by"
        menu.clearOnNewSelection = true
        
        let handler = { (item: ListMenuItem, order: FavorableSortBy) in
            
            menu.setItem(item, selected: true)
            self.sortResources(by: order)
            
            self.delegate?.dismissSortMenu()
        }
        
        menu.addItem(ListMenuItem(text: "Alphabetical", icon: #imageLiteral(resourceName: "ic_sort_by_alpha"), tint: Color.blue.darken1, selected: false) { handler($0, .alphabetical) })
        menu.addItem(ListMenuItem(text: "Favorites", icon: #imageLiteral(resourceName: "ic_favorite"), tint: Color.pink.base, selected: true){ handler($0, .favorites) })
        menu.addItem(ListMenuItem(text: "Cancel", icon: #imageLiteral(resourceName: "ic_close")){ _ in self.delegate?.dismissSortMenu() })
    }
    
    private func sortResources(by order: FavorableSortBy)
    {
        self.resources.sort(by: order.comparator)
        self.collectionView.reloadData()
    }

    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
        delegate?.presentSortMenu(controller: sortMenuController)
    }
    
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = (name: String, resources: [Resource], handler: SelectionHandler?)
    
    /**
     * Set the name, dining halls, and selection callback handler.
     * The carousel collectionView is reloaded.
     */
    public func setData(_ data: DataType)
    {
        self.resources = data.resources
        self.groupLabel.text = data.name
        self.selectionHandler = data.handler
        
        self.sortResources(by: .favorites)
        self.collectionView.reloadData()
    }
    
    
    // ========================================
    // MARK: - UICollectionViewDataSource
    // ========================================
    
    /// Carousel only has 1 section.
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    /// Return the number of tiles in the group.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return resources.count
    }
    
    /// Get a ResourceTile and pass it the corresponding Resource.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kResourceTileID, for: indexPath) as! ResourceTile
        cell.setData( self.resources[indexPath.item] )
        
        return cell
    }
    
    
    
    // ========================================
    // MARK: - UICollectionViewDelegate
    // ========================================
    
    /// When a ResourceTile is selected (tapped), call the selectionHandler with the Resource.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.selectionHandler?( self.resources[indexPath.item] )
    }
}
