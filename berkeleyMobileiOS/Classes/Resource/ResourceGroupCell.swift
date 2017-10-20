
import UIKit

fileprivate let kResourceTileID = "ResourceTile"

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
    
    
    /// Configure the collectionView.
    override func awakeFromNib()
    {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
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
        self.groupLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)
        
        self.selectionHandler = data.handler
        
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
