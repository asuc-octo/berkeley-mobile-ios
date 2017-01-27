
import UIKit

fileprivate let kLocationTileID = "LocationTile"

/**
 * GroupCell shows a carousel of locations as a CollectionView of LocationTiles.
 * Whenever a LocationTile is selected (tapped), the handler specified through setData() is called.
 */
class DiningGroupCell: UITableViewCell, RequiresData, UICollectionViewDataSource, UICollectionViewDelegate
{
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
    typealias HandlerType = (DiningHall) -> Void
    typealias DataType = (name: String, halls: [DiningHall], selectionHandler: HandlerType?)
    
    private var halls: [DiningHall]!
    private var selectionHandler: HandlerType?
    
    /**
     * Set the name, dining halls, and selection callback handler.
     * The carousel collectionView is reloaded.
     */
    public func setData(_ data: DataType)
    {
        self.halls = data.halls
        self.groupLabel.text = data.name
        self.selectionHandler = data.selectionHandler
        
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
    
    /// Return the number of halls/tiles in the group.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return halls.count
    }
    
    /// Get a LocationTile and pass it the corresponding DiningHall.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let hall = halls[indexPath.item]
        let favorited = FavoriteStore.sharedInstance.contains(type: DiningHall.self, name: hall.name)
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kLocationTileID, for: indexPath) as! LocationTile
        cell.setData( (hall, favorited) )
        
        return cell
    }
    
    
    
    // ========================================
    // MARK: - UICollectionViewDelegate
    // ========================================
    
    /// When a LocationTile is selected (tapped), call the selectionHandler with the DinigHall.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.selectionHandler?( self.halls[indexPath.item] )
    }
}
